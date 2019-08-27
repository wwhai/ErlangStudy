%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:42
%%%-------------------------------------------------------------------
-module(tcp_server).
-export([start_parallel_server/1]).
%%
-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).

-import(ets, [insert_new/2]).

%服务端
start_parallel_server(Port) ->
  %创建一个全局的ets表，存放客户端的id
  ets:new(clients_table, [ordered_set, public, named_table, {write_concurrency, true}, {read_concurrency, true}]),

  case gen_tcp:listen(Port, ?TCP_OPTIONS) of
    {ok, LocalHostPort} ->
      io:format("Server start successful at port:~p ~n", [Port]),
      listen(LocalHostPort);
    {error, Why} ->
      io:format("Server start failed with error:~p ~n", [Why])
  end.

listen(LocalHostPort) ->
  case gen_tcp:accept(LocalHostPort) of
    {ok, RemoteSocket} ->
      %每连接到一个客户端，把id插入到ets表中
      io:format("New remote socket connected:~p ~n", [inet:peername(RemoteSocket)]),

      case ets:last(clients_table) of
        '$end_of_table' ->
          ets:insert(clients_table, {1, RemoteSocket});
        Other ->
          ets:insert(clients_table, {Other + 1, RemoteSocket})
      end,
      spawn(fun() -> loop(RemoteSocket) end),

      listen(LocalHostPort);

    {error, Reason} ->
      io:format("Error : ~p~n", [Reason])
  end.
%%
loop(Socket) ->
  io:format("Start loop:  ~p ~n", [Socket]),
  case gen_tcp:recv(Socket, 0) of
    {ok, Data} ->
      io:format("Receive raw byte data ~p~n", [Data]),

      read_header(Data),
      loop(Socket);
    {error, closed} ->
      io:format("Socket [~p] close ~n", [Socket])
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


read_header(Data) ->
  case (Data) of
    <<Protocol:4, GramType:4, Length:4, PayLoad/binary>> ->
      io:format("Head is [~p] and Type is [~p] Length is [~p] PayLoad is[~p] ~n", [Protocol, GramType, Length, PayLoad]);
    _ -> io:format("Datagram invalid ~n")
  end.
