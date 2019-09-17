%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 九月 2019 22:46
%%%-------------------------------------------------------------------
-module(tcp_server_app).
-author("wangwenhai").

%% API
-export([]).
-behaviour(application).
-export([start/2, stop/1, start/0]).
-define(PORT, 5510).

start() ->
  start(?MODULE, ?MODULE).

start(_Type, _Args) ->
  io:format("TCP server read to start. ~p ~n",[time()]),
  case tcp_server_supervisor:start_link(?PORT) of
    {ok, Pid} ->
      {ok, Pid};
    Other ->
      {error, Other}
  end.

stop(_S) ->
  ok.