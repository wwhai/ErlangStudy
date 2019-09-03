%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:41
%%%-------------------------------------------------------------------
-module(hello_world).
-author("75195").

%% API
-export([start/0]).
start() ->
  test_tuple({config, {ip,"localhost", port, 8888}}),
  io:format("HelloWorld---Erlang! ~n").

test_tuple(Config) ->
  {config, {ip,Ip, port, Port}} = Config,
  io:format("Config : Ip is [~p] Port is [~p] ~n", [Ip, Port]).
