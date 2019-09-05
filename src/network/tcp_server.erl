%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:42
%%%-------------------------------------------------------------------
-module(tcp_server).
-export([start/1]).
-import(string, [equal/2]).

%%
-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).

%服务端
start(Port) ->
  %创建一个全局的ets表，存放客户端的id
  ets:new(clients_table, [ordered_set, public, named_table, {write_concurrency, true}, {read_concurrency, true}]),

  case gen_tcp:listen(Port, ?TCP_OPTIONS) of
    {ok, LocalHostPort} ->
      io:format("Server start successful at port:~p ~n", [Port]),
      listen(LocalHostPort),
      LocalHostPort;
    {error, Why} ->
      io:format("Server start failed with error:~p ~n", [Why]),
      Why

  end.

%% 当端口开启以后进行监听
listen(LocalHostPort) ->
  case gen_tcp:accept(LocalHostPort) of
    {ok, RemoteSocket} ->
      %每连接到一个客户端，把id插入到ets表中
      io:format("New remote socket connected:~p ~n", [inet:peername(RemoteSocket)]),
      spawn(fun() -> loop(RemoteSocket) end),
      listen(LocalHostPort);
    {error, Reason} ->
      io:format("Error : ~p~n", [Reason])
  end.

%% loop是循环接受消息用的，第一个参数表示监听的哪个Socket，Buffer表示进来的数据【字节流】
%%
loop(Socket) ->
  case gen_tcp:recv(Socket, 0) of
    {ok, Data} ->
      %% inet:setopts(Socket, [{active, once}]),
      %% io:format("Receive data ~p~n", [Data]),
      %% 重点讲一下这段代码：decode_header函数是用来解包的，数据包的定义如下
      %% <<"TTCP", GramType:8, QOS:8, Size:16, BitString:Size/binary>>
      decode_header(Socket, <<Data/binary>>),
      loop(Socket);
    {error, closed} ->
      io:format("Socket [~p] close ~n", [Socket])

  end.


%% 解包
%% Erlang果然是专门做网络通信的语言，这个数据解包感觉真的秒杀所有语言，想一下之前用Java做的解包代码，反正是很难受了
%% Erlang天然自带二进制的便捷操作，对于格式复杂的数据报文，解包起来真是爽的一批。
%% 包类型：
%% 0 心跳包
%% 1 登陆
%% 2 发送数据
%% 3 加入群组
%% 4 退出群组
%% 5 发广播
decode_header(Socket, <<"TTCP", GramType:8, QOS:8, Size:16, PayLoad/binary>>) ->
  %%io:format("Type is [~p] QOS is [~p] Size is [~p] PayLoad is  [~p] ~n", [GramType, QOS, Size, PayLoad]),
  %%io:format("LeastBin is [~p] ~n", [LeastBin]),
  case GramType of
    0 ->
      <<Username:Size/binary>> = PayLoad,
      io:format("HeartBeat from [~p] ~n", [binary_to_list(Username)]);
    1 ->
      <<UsernameSize:8, PasswordSize:8, Username:UsernameSize/binary, Password:PasswordSize/binary>> = PayLoad,
      spawn(fun() -> hand_login(Socket, Username, Password) end);
    2 -> io:format("Send message");
    3 -> io:format("Join group");
    4 -> io:format("Exit group");
    5 -> io:format("Boardcast");
    _ -> ok
  end.

%% 登陆处理
hand_login(Socket, Username, Password) ->
  io:format("Socket [~p] Login request Username is [~p] Password is  [~p] ~n", [Socket, binary_to_list(Username), binary_to_list(Password)]),
  %% 模拟登陆效果,此处应该在数据库里面查找
  Status = equal(binary_to_list(Username), "username"),
  case Status of true ->
    case ets:last(clients_table) of
      '$end_of_table' ->
        ets:insert(clients_table, {1, {username, Username, socket, Socket}});
      Other ->
        ets:insert(clients_table, {Other + 1, {username, Username, socket, Socket}}),
        ok
    end;
    false ->
      gen_tcp:close(Socket),
      failure
  end.