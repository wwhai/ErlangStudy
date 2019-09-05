%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:43
%%%-------------------------------------------------------------------
-module(tcp_client).
-export([start/1]).
-define(USERNAME, <<"wwhai">>).
-define(PASSWORD, <<"password">>).

start(Port) ->
  case gen_tcp:connect("127.0.0.1", Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]) of
    {ok, Socket} ->
      io:format("Request login ~n"),
      send_data(Socket, login(<<"username">>, <<"password">>)),
      io:format("Heart beat ~n"),
      send_data(Socket, heart_beat(<<"751957846">>));
    _ -> io:format("Error ~n")

  end.

send_data(Socket, Data) ->
  gen_tcp:send(Socket, Data).


%%pack(cli, 10000, {Rid, Srv_id, Msg}) ->
%%  Data   = <<Rid:32, byte_size(Srv_id):16, Srv_id/binary, byte_size(Msg):16, Msg/binary>>,
%%  Packet = <<(byte_size(Data) + 2):32, 10000:16, Data/binary>>,
%%  {ok, Packet}.
%%


heart_beat(Username)
  when is_binary(Username) ->
  GramType = 0,
  QOS = 2,
  Size = byte_size(Username),
  UsernameSize = byte_size(Username),

  <<"TTCP", GramType:8, QOS:8, Size:16, Username:UsernameSize/binary>>.

login(Username, Password)
  when is_binary(Username) and is_binary(Password) ->
  GramType = 1,
  QOS = 2,
  UsernameSize = byte_size(Username),
  PasswordSize = byte_size(Password),
  Size = UsernameSize + PasswordSize,
  <<"TTCP", GramType:8, QOS:8, Size:16, UsernameSize:8, PasswordSize:8, Username:UsernameSize/binary, Password:PasswordSize/binary>>.