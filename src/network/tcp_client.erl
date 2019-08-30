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
  %% 打包
  GramType = 1,
  QOS = 2,
  PayLoad = <<"HelloWorldErlangHHHHH">>,
  Size = bit_size(PayLoad),
  Packet1 = <<"TTCP", GramType:8, QOS:8, Size:16, PayLoad:Size/bitstring>>,
  io:format("Send 1~n"),
  send_data(Socket, Packet1),
  io:format("Send 2~n"),
  Packet2 = <<"TTCP", GramType:8, QOS:8, Size:16, PayLoad:Size/bitstring>>,
  send_data(Socket, Packet2),

  Socket.


send_data(Socket, Data) when is_list(Data) orelse is_binary(Data) orelse is_bitstring(Data) ->
  gen_tcp:send(Socket, Data),
  receive
    {tcp, Socket, Bin} ->
      io:format("recv ~p~n", [Bin]);
    {tcp_closed, Socket} ->
      io:format("remote server closed!~n")
  end.
