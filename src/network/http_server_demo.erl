%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:42
%%%-------------------------------------------------------------------
-module(http_server_demo).
-export([listen/1]).
%%
-define(TCP_OPTIONS, [binary, {packet, 4}, {active, false}, {reuseaddr, true}]).

% Call echo:listen(Port) to start the service.
listen(Port) ->
  case gen_tcp:listen(Port, ?TCP_OPTIONS) of
    {ok, LocalSocket} ->
      io:format("Server success listening at port:  ~p ~n", [Port]),
      io:format("Server begin listening with options :  ~p ~n", [?TCP_OPTIONS]),
      %%gen_tcp:listen(Port, ?TCP_OPTIONS),
      accept(LocalSocket);
    {error, Reason} ->
      io:format("Server start error :  ~p ~n", [Reason])
  end.

% Wait for incoming connections and spawn the echo loop when we get one.
accept(LocalSocket) ->
  io:format("Server start block thread at local socket:  ~p ~n", [LocalSocket]),

  {ok, Socket} = gen_tcp:accept(LocalSocket),
  io:format("Client success accept:  ~p ~n", [Socket]),
  spawn(fun() -> loop(Socket) end),
  accept(LocalSocket).

% Echo back whatever data we receive on Socket.
loop(Socket) ->
  io:format("Start loop:  ~p ~n", [Socket]),
  case gen_tcp:recv(Socket, 0) of
    {ok, Data} ->
      io:format("recv ~p~n", [Data]),
      gen_tcp:send(Socket, <<"HTTP/1.1 200 OK\r\n\n Hello World,This is Erlang Http response">>),
      %%  HTTP 完成以后关闭Socket
      %% gen_tcp:close(Socket),
      %%  尾递归 重新开始监听端口
      loop(Socket);
    {error, closed} ->
      ok
  end.