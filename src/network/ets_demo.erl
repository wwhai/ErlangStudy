%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 八月 2019 20:32
%%%-------------------------------------------------------------------
-module(ets_demo).
-author("75195").

%% API
-export([start/0]).
start() ->
  ets:new(clients, [ordered_set, public, named_table, {write_concurrency, true}, {read_concurrency, true}]),
  ets:insert(clients, {name, "wwhai"}),
  io:format("ETS last: ~p ~n", [ets:last(clients)]).