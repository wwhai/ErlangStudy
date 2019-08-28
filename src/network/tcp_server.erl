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
%%
-define(TCP_OPTIONS, [binary, {packet, 2}, {active, false}, {reuseaddr, true}]).

-import(ets, [insert_new/2]).

%服务端
start(Port) ->
  %创建一个全局的ets表，存放客户端的id
  ets:new(clients_table, [ordered_set, public, named_table, {write_concurrency, true}, {read_concurrency, true}]),
  Pid = spawn_link(fun() ->
    {ok, LocalHostPort} = gen_tcp:listen(Port, ?TCP_OPTIONS),
    io:format("Server start successful at port:~p ~n", [Port]),
    listen(LocalHostPort)
                   end
  ),
  {ok, Pid}.

%% 当端口开启以后进行监听
listen(LocalHostPort) ->
  case gen_tcp:accept(LocalHostPort) of

    {ok, RemoteSocket} ->
      %每连接到一个客户端，把id插入到ets表中
      io:format("New remote socket connected:~p ~n", [inet:peername(RemoteSocket)]),

%%      case ets:last(clients_table) of
%%        '$end_of_table' ->
%%          ets:insert(clients_table, {1, RemoteSocket});
%%        Other ->
%%          ets:insert(clients_table, {Other + 1, RemoteSocket})
%%      end,

      spawn(fun() -> listen(LocalHostPort) end),

      loop(RemoteSocket, <<>>);

    {error, Reason} ->
      io:format("gen_tcp:accept error : ~p~n", [Reason])
  end.


%% 循环接收消息
loop(Socket, Buffer) ->
  io:format("Start loop:  ~p ~n", [Socket]),
  case gen_tcp:recv(Socket, 0) of
    {ok, Data} ->
      io:format("Receive raw byte data ~p~n", [Data]),
      Data1 = read_header(<<Buffer/binary, Data/binary>>),
      loop(Socket, Data1);
    {error, Reason} ->
      io:format("Socket [~p] Reason = ~p ~n", [Socket, Reason])
  end.

%% 读取报文头[4个Byte=32bit]
%% 报文结构如下
%% 协议类型[4bit(固定值:TTCP)]-报文类型(4bit=16种(目前就4种))-消息长度[8bit(最大支持)](1mb=8388608bit)
%% 报文类型表:
%% 0001->[1]:请求连接
%% 0010->[2]:请求登陆
%% 0011->[3]:发送消息
%% 0100->[4]:广播消息
%% 0101->[5]:心跳包
%% 0111->[6]:
%% 1000->[7]:

read_header(<<Size:16, Bin:Size/binary, Bin2/binary>>) ->
  <<Protocol:8, GramType:8, Length:8, PayLoad/binary>> = Bin,
  io:format("Head is [~p] and Type is [~p] Length is [~p] PayLoad is[~p] ~n", [Protocol, GramType, Length, PayLoad]),
  read_header(Bin2);
read_header(Bin) ->
  Bin.

%%read_header(<<Protocol:1, GramType:1, Length:1, PayLoad/binary>>) ->
%%
%%  io:format("Head is [~p] and Type is [~p] Length is [~p] PayLoad is[~p] ~n", [Protocol, GramType, Length, PayLoad]).
