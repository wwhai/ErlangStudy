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

start(Port) ->
  {ok, Socket} = gen_tcp:connect("127.0.0.1", Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
  io:format("1~n"),
  send_data(Socket, gen_packet()),
  io:format("2~n"),
  send_data(Socket, gen_packet()).


send_data(Socket, Data) ->
  gen_tcp:send(Socket, Data).


gen_packet() ->
  GramType = 1,
  QOS = 2,
  PayLoad = <<"HelloWorldErlangHHHHH">>,
  Size = bit_size(PayLoad),
  <<"TTCP", GramType:8, QOS:8, Size:16, PayLoad:Size/bitstring>>.