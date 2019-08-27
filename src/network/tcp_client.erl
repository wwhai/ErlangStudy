%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:43
%%%-------------------------------------------------------------------
-module(tcp_client).
-export([start/1, close/1]).

start(Port) ->
  {ok, Socket} = gen_tcp:connect("127.0.0.1", Port, [binary, {packet, raw}, {active, true}, {reuseaddr, true}]),
  send_data(Socket, "TTCP00010001payloadString"),
  Socket.


send_data(Socket, Data) when is_list(Data) orelse is_binary(Data) ->
  gen_tcp:send(Socket, Data),
  receive
    {tcp, Socket, Bin} ->
      io:format("recv ~p~n", [Bin]);
    {tcp_closed, Socket} ->
      io:format("remote server closed!~n")
  end.

close(Socket) when is_port(Socket) ->
  gen_tcp:close(Socket).