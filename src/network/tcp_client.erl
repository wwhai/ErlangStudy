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
  {ok, Socket} = gen_tcp:connect("127.0.0.1", Port, [binary, {packet, 4}, {active, true}, {reuseaddr, true}]),
  send_data(Socket, term_to_binary("10000000011111111222222223333333344444444")),
  send_data(Socket, term_to_binary("20000000011111111222222223333333344444444")),
  send_data(Socket, term_to_binary("30000000011111111222222223333333344444444")),
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