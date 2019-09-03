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
-define(USERNAME,"wwhai").
-define(PASSWORD,"password").

start(Port) ->
  case gen_tcp:connect("127.0.0.1", Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]) of
    {ok, Socket} -> io:format("1~n"),
      io:format("1~n"),
      send_data(Socket, gen_packet(<<"2">>)),
      io:format("2~n"),
      send_data(Socket, heart_beat(<<"1">>));
    _ -> io:format("Error ~n")

  end.

send_data(Socket, Data) ->
  gen_tcp:send(Socket, Data).


gen_packet(BitString)

  when is_bitstring(BitString) ->
  GramType = 1,
  QOS = 2,
  Size = bit_size(BitString),
  <<"TTCP", GramType:8, QOS:8, Size:16, BitString:Size/bitstring>>.

heart_beat(Username)
  when is_bitstring(Username) ->
  GramType = 0,
  QOS = 2,
  Size = bit_size(Username),
  <<"TTCP", GramType:8, QOS:8, Size:16, Username:Size/bitstring>>.

login(Username, Password)
  when is_bitstring(Username) and is_bitstring(Password) ->
  GramType = 1,
  QOS = 2,
  Size = bit_size(Username),
  <<"TTCP", GramType:8, QOS:8, Size:16, Username:Size/bitstring>>.