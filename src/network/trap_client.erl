%%%-------------------------------------------------------------------
%%% @author Wangwenhai
%%% @copyright (C) 2019, <Wangwenhai>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:43
%%%-------------------------------------------------------------------
-module(trap_client).
-export([start/1, start/0]).
-define(USERNAME, <<"username">>).
-define(PASSWORD, <<"password">>).
-record(client, {client_id, ip}).
start(Port) ->
  case gen_tcp:connect("127.0.0.1", Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]) of
    {ok, ServerSocket} ->
      io:format("Request login ~n"),
      send_data(ServerSocket, login(<<"username">>, <<"password">>)),
      ControlPid = spawn(fun() -> loop(ServerSocket) end),
      gen_tcp:controlling_process(ServerSocket, ControlPid),
      ServerSocket;
    {error, Why} -> io:format("Error ~p~n", [Why])

  end.
start() ->
  start(8888).

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

login(Username, Password)
  when is_binary(Username) and is_binary(Password) ->
  GramType = 1,
  QOS = 2,
  UsernameSize = byte_size(Username),
  PasswordSize = byte_size(Password),
  Size = UsernameSize + PasswordSize,
  <<"TTCP", GramType:8, QOS:8, Size:16, UsernameSize:8, PasswordSize:8, Username:UsernameSize/binary, Password:PasswordSize/binary>>.