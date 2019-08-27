
%%%-------------------------------------------------------------------
%%% @author 94217
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 十一月 2018 15:35
%%%-------------------------------------------------------------------
-module(chatting_client).
-author("94217").

%% API
-export([connect/0,
  clientloop/1,
  create_channel/2,
  list_channel/1,
  join_channel/2,
  user/2,
  quick_channel/2,
  talk/3]).

%连接服务器
connect() ->
  %%请求连接
  {ok, Socket} = gen_tcp:connect("localhost", 6789, [binary, {packet, 4}, {active, true}]),

  %%开启一个进程接收服务器消息
  Pid = spawn(client, clientloop, [Socket]),
  gen_tcp:controlling_process(Socket, Pid),
  Socket.

%%接收服務器的消息
clientloop(Socket) ->
  receive
    {tcp, Socket, Bin} ->
      io:format("asda = ~p~n", [binary_to_term(Bin)]),
      case binary_to_term(Bin) of
        %%创建频道是否成功
        create_channel_ok ->
          io:format("From Sever : create channel sucessful ~n"),
          clientloop(Socket);

        %%列出所有频道
        {list_channel, Reply} ->
          [showchannel(Channelname) || {_, Channelname} <- Reply],
          clientloop(Socket);

        %%加入频道是否成功
        nochannel ->
          io:format("add channel fail ~n"),
          clientloop(Socket);
        joinsucess ->
          io:format("add channel sucessful ~n"),
          clientloop(Socket);

        %%退出频道是否成功
        deleteok ->
          io:format("return channel sucessful"),
          clientloop(Socket);

        %%列出频道内所有的用户
        {user, AceReply} ->
          [showuser(User) || {_, User} <- AceReply],
          clientloop(Socket);

        {data, Sok, Re} ->
          io:format("data : ~p~n", [Re]),
          clientloop(Socket)


      end
  end.
%%创建频道
create_channel(Socket, Pname) ->
  gen_tcp:send(Socket, term_to_binary({creat, Pname})).

%%列出所有频道
list_channel(Socket) ->
  gen_tcp:send(Socket, term_to_binary(showlist)).

%%加入频道
join_channel(Socket, Pname) ->
  gen_tcp:send(Socket, term_to_binary({add, Pname})).

%%退出频道
quick_channel(Socket, Pname) ->
  %%向服务器发送退出的频道名
  gen_tcp:send(Socket, term_to_binary({retchannel, Pname})).
%%向频道讲话
talk(Socket, Pname, Str) ->
  gen_tcp:send(Socket, term_to_binary({talk, Pname, Str})),
  io:format("send sucess").

%%列出频道所有用户
user(Socket, Pname) ->
  gen_tcp:send(Socket, term_to_binary({showuser, Pname})).

%%打印用户
showuser(User) ->
  io:format("user : ~p~n", [User]).

%%打印频道
showchannel(Channelname) ->
  io:format("channel : ~p~n", [Channelname]).