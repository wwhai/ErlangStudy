%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 九月 2019 22:48
%%%-------------------------------------------------------------------
-module(tcp_server_supervisor).
-author('wwhai').
-behaviour(supervisor).
-export([start_link/1, start_child/0]).
-export([init/1]).
-define(SERVER, ?MODULE).

start_link(LocalPort) ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, [LocalPort]).

start_child() ->
  supervisor:start_child(?SERVER, []).

init([LocalPort]) ->
  io:format("Init LocalPort"),

  Server = {trap_otp_server_handler, {trap_otp_server_handler, start_link, [LocalPort]},
    temporary, brutal_kill, worker, [trap_otp_server_handler]},
  Children = [Server],
  RestartStrategy = {simple_one_for_one, 0, 1},
  {ok, {RestartStrategy, Children}}.