%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 九月 2019 22:46
%%%-------------------------------------------------------------------
-module(trap_otp_server_app).
-author("75195").

%% API
-export([]).
-behaviour(application).
-export([start/2, stop/1, start/0]).
-define(DEFAULT_PORT, 5510).

start() ->
  start(?MODULE, ?MODULE).
start(_Type, _Args) ->
  Options = [binary, {packet, 2}, {reuseaddr, true},
    {keepalive, true}, {backlog, 30}, {active, false}],
  case gen_tcp:listen(get_app_env(listen_port, ?DEFAULT_PORT), Options) of
    {ok, LocalPort} -> io:format("LocalPort [~p] listening successful! ~n", [get_app_env(listen_port, ?DEFAULT_PORT)]),
      case tcp_server_supervisor:start_link(LocalPort) of
        {ok, Pid} ->
          listen(LocalPort),
          tcp_server_supervisor:start_child(),
          {ok, Pid};
        Other ->
          {error, Other}
      end,
      LocalPort;
    {error, Why} -> io:format("LocalPort [~p] listening failure! Because: ~n", [Why])
  end.


listen(LocalHostPort) ->
  case gen_tcp:accept(LocalHostPort) of
    {ok, RemoteSocket} ->
      {ok, {Ip, Port}} = inet:peername(RemoteSocket),
      io:format("New remote socket [~p] connected with port [~p]~n", [Ip, Port]),
      Pid = spawn(fun() -> loop(RemoteSocket) end),
      listen(LocalHostPort),
      Pid;
    {error, Why} ->
      io:format("RemoteHost error with message: ~p~n", [Why])
  end.

loop(Socket) ->
  case gen_tcp:recv(Socket, 0) of
    {ok, Data} ->
      %% inet:setopts(Socket, [{active, once}]),
      loop(Socket);
    {error, closed} ->
      io:format("Socket [~p] close ~n", [inet:peername(Socket)])

  end.


stop(_S) ->
  ok.

get_app_env(Opt, Default) ->
  case application:get_env(application:get_application(), Opt) of
    {ok, Val} -> Val;
    _ ->
      case init:get_argument(Opt) of
        [[Val | _]] -> Val;
        error -> Default
      end
  end.