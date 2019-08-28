-module(tcp_parallel_server).
-define(TCP_OPT, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]).
-export([start/0]).
start() ->
  case gen_tcp:listen(6666, [{active, false}, {packet, 2}]) of
    {ok, ListenSock} ->
      start_servers(0, ListenSock),
      {ok, Port} = inet:port(ListenSock),
      Port;
    {error, Reason} ->
      {error, Reason}
  end.

start_servers(0, _) ->
  ok;
start_servers(Num, LS) ->
  spawn(?MODULE, server, [LS]),
  start_servers(Num - 1, LS).

server(LS) ->
  case gen_tcp:accept(LS) of
    {ok, S} ->
      loop(S),
      server(LS);
    Other ->
      io:format("accept returned ~w - goodbye!~n", [Other]),
      ok
  end.

loop(S) ->
  inet:setopts(S, [{active, once}]),
  receive
    {tcp, S, Data} ->
      io:format("Socket data closed [~w]~n", [Data]),

      loop(S);
    {tcp_closed, S} ->
      io:format("Socket ~w closed [~w]~n", [S, self()]),
      ok
  end.