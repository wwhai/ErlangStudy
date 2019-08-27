
%%%-------------------------------------------------------------------
%%% @author 94217
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 十一月 2018 15:32
%%%-------------------------------------------------------------------
-module(chatting_server).
-author("94217").
-export([start/0,
  create_chanel/2,
  loop/1]).

% 启动一个服务器
start() ->
  %创建一个全局的ets表，存放频道名和频道内的用户
  ets:new(channel, [bag, public, named_table, {write_concurrency, true}, {read_concurrency, true}]),

  case gen_tcp:listen(6789, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]) of
    {ok, Listen} ->
      spawn(fun() -> par_connect(Listen) end);
    {error, Why} ->
      io:format("server start error,the reason maybe ~p~n
            now is going restart~n", [Why])
  end.

%接受连接
par_connect(Listen) ->
  case gen_tcp:accept(Listen) of
    {ok, Socket} ->
      spawn(fun() -> par_connect(Listen) end),
      loop(Socket);
    {error, Why} ->
      io:format("connect fail:~w~n", [Why])
  end.
%监听消息
loop(Socket) ->
  receive
    {tcp, Socket, Bin} ->
      L = binary_to_term(Bin),
      io:format("data = ~p~n", [L]),
      case binary_to_term(Bin) of
        %%创建频道
        {creat, Pname} ->
          Reply = create_chanel(Socket, Pname),
          gen_tcp:send(Socket, term_to_binary(Reply)),
          loop(Socket);
        %%列出频道
        showlist ->
          list_all_channel(Socket),
          loop(Socket);

        %%加入特定频道
        {add, Pname} ->
          {true, Reply} = add_channel(Pname, Socket),
          gen_tcp:send(Socket, term_to_binary(Reply)),
          loop(Socket);
        %%退出当前频道
        {retchannel, Pname} ->
          {ok, Reply} = ret_channel(Pname, Socket),
          gen_tcp:send(Socket, term_to_binary(Reply)),
          loop(Socket);

        %%在频道内发送消息
        {talk, Pname, Str} ->
          Reply = channel_talk(Socket, Pname, Str),
          loop(Socket);
        %%列出频道内所有用户
        {showuser, Pname} ->
          {true, Userlist} = find_user(Pname),
          gen_tcp:send(Socket, term_to_binary({user, Userlist})),
          loop(Socket)
      end

  end.

%%创建频道
create_chanel(Socket, Chaname) ->
  io:format("Data~p~n", [Chaname]),
  ets:insert(channel, {creat, Chaname}),
  create_channel_ok.
%%列出频道
list_all_channel(Socket) ->
  L = ets:lookup(channel, creat),
  io:format("~p~n", [L]),
  gen_tcp:send(Socket, term_to_binary({list_channel, L})).

%%加入特定频道
add_channel(Pname, Socket) ->
  %%判断频道是否存在
  Lis = [ChannelList || {creat, ChannelList} <- ets:tab2list(channel)],  %%列出所有频道名
  io:format("~p~n", [Lis]),
  case lists:member(Pname, Lis) of                                        %%查看所加入的频道名是否存在
    false ->
      {true, nochannel};
    true ->
      ets:insert(channel, {Pname, Socket}),
      {true, joinsucess}
  end.

%%退出频道
ret_channel(Pname, Socket) ->
  %%删除表里频道名对应的套接字
  ets:delete_object(channel, {Pname, Socket}),
  {ok, deleteok}.

%%在频道内发送消息
channel_talk(Socket, Pname, Str) ->
  %%查看该用户是否在频道内
  io:format("str = ~p~n", [Str]),
  ChannelName = ets:lookup(channel, Pname),
  case lists:member({Pname, Socket}, ChannelName) of
    true ->
      io:format("is channel ~n"),
      sendtalk(Pname, Str);
    false ->
      false
  end.

%%列出频道内所有用户
find_user(Pname) ->
  User = ets:lookup(channel, Pname),
  io:format("Userlist : ~p~n", [User]),
  {true, User}.
%%将消息转发给所有频道内所有的套接字
sendtalk(Pname, Str) ->
  %%将频道内所有的套接字找出来
  AllSocketPname = ets:lookup(channel, Pname),
  [sendStr(Socket, Str) || {Pname, Socket} <- AllSocketPname].
sendStr(Socket, Str) ->
  gen_tcp:send(Socket, term_to_binary({data, Socket, Str})),
  io:format("send user : ~p~n", [Socket]).