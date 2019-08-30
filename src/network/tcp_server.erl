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
-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).

%服务端
start(Port) ->
  %创建一个全局的ets表，存放客户端的id
  ets:new(clients_table, [ordered_set, public, named_table, {write_concurrency, true}, {read_concurrency, true}]),

  case gen_tcp:listen(Port, ?TCP_OPTIONS) of
    {ok, LocalHostPort} ->
      io:format("Server start successful at port:~p ~n", [Port]),
      listen(LocalHostPort);
    {error, Why} ->
      io:format("Server start failed with error:~p ~n", [Why])
  end.

%% 当端口开启以后进行监听
listen(LocalHostPort) ->
  case gen_tcp:accept(LocalHostPort) of
    {ok, RemoteSocket} ->
      %每连接到一个客户端，把id插入到ets表中
      io:format("New remote socket connected:~p ~n", [inet:peername(RemoteSocket)]),
      gen_tcp:send(RemoteSocket, <<"FUCKU!">>),

      spawn(fun() -> loop(RemoteSocket, <<>>) end),
      listen(LocalHostPort);
    {error, Reason} ->
      io:format("Error : ~p~n", [Reason])
  end.

%% <84,84,67,80,1,2,0,168,72,101,108,108,111,87,111,114,108,100,69, 114,108,97,110,103,72,72,72,72,72>>
loop(Socket, Buffer) ->
  io:format("Start loop:  ~p ~n", [Socket]),
  case gen_tcp:recv(Socket, 0) of
    {ok, Data} ->
      %% inet:setopts(Socket, [{active, once}]),
      io:format("Receive data ~p~n", [Data]),
      LeastBinData = read_header(<<Buffer/binary, Data/binary>>),
      loop(Socket, LeastBinData);
    {error, closed} ->
      io:format("Socket [~p] close ~n", [Socket])

  end.


%% 解包<<84,84,67,80,1,2,0,128,72,101,108,108,111,87,111,114,108,100,69,114,108, 97,110,103>>
read_header(<<"TTCP", GramType:8, QOS:8, Size:16, PayLoad:Size/bitstring, LeastBin/binary>>) ->
  io:format("Type is [~p] QOS is [~p] Size is [~p] PayLoad is[~p] ~n", [GramType, QOS, Size, PayLoad]),
  io:format("LeastBin is [~p]", [LeastBin]),
  read_header(LeastBin);
%% 读取剩下的
read_header(Bin) ->
  Bin.