%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:43
%%%-------------------------------------------------------------------
-module(tcp_client).
-export([start/1, start/0]).
-define(USERNAME, <<"username">>).
-define(PASSWORD, <<"password">>).
-record(client, {client_id, ip}).
start(Port) ->
  case gen_tcp:connect("127.0.0.1", Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]) of
    {ok, ServerSocket} ->
      io:format("Request login ~n"),
      send_data(ServerSocket, login(<<"11111">>)),
      ControlPid = spawn(fun() -> loop(ServerSocket) end),
      gen_tcp:controlling_process(ServerSocket, ControlPid),
      ServerSocket;
    {error, Why} -> io:format("Error ~p~n", [Why])

  end.

start() ->
  start(5000).

loop(Socket) ->
  case gen_tcp:recv(Socket, 0) of
    {ok, Data} ->
      io:format("Receive data ~p~n", [Data]),
      loop(Socket);
    {error, closed} ->
      io:format("Socket [~p] close ~n", [Socket])

  end.


send_data(Socket, Data) ->
  gen_tcp:send(Socket, Data).


heart_beat(Username)
  when is_binary(Username) ->
  GramType = 0,
  QOS = 2,
  Size = byte_size(Username),
  UsernameSize = byte_size(Username),

  <<"TTCP", GramType:8, QOS:8, Size:16, Username:UsernameSize/binary>>.


publish(Msg)
  when is_binary(Msg) ->
  GramType = 2,
  QOS = 2,
  Size = byte_size(Msg),
  MsgSize = byte_size(Msg),
  <<"TTCP", GramType:8, QOS:8, Size:16, Msg:MsgSize/binary>>.

login(ClientId)
  when is_binary(ClientId)->
  Mode = 1,
  Type = 2,
  ClientIdSize = byte_size(ClientId),
  << Mode:4, Type:4, ClientIdSize:16, ClientId/binary>>.
