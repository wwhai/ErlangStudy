%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <wwhai>
%%% @doc
%%%
%%% @end
%%% Created : 15. 九月 2019 22:40
%%%-------------------------------------------------------------------
-module(trap_otp_server_handler).
-author("wwhai").
-behaviour(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
  terminate/2, code_change/3]).
-record(state, {lsock, socket, addr}).

start_link(LSock) ->
  gen_server:start_link(?MODULE, [LSock], []).

init([Socket]) ->
  io:format("Init Socket ~p \n", [Socket]),

  inet:setopts(Socket, [{active, once}, {packet, 2}, binary]),
  {ok, #state{lsock = Socket}, 0}.

handle_call(Msg, _From, State) ->
  {reply, {ok, Msg}, State}.

handle_cast(stop, State) ->
  {stop, normal, State}.

handle_info({tcp, Socket, Data}, State) ->
  inet:setopts(Socket, [{active, once}]),
  io:format("~p got message ~p\n", [self(), Data]),
  ok = gen_tcp:send(Socket, <<"Echo back : ", Data/binary>>),
  {noreply, State};

handle_info({tcp_closed, Socket}, #state{addr = Addr} = StateData) ->
  error_logger:info_msg("~p Client ~p disconnected.\n", [self(), Addr]),
  {stop, normal, StateData};

handle_info(timeout, #state{lsock = LSock} = State) ->
  {ok, ClientSocket} = gen_tcp:accept(LSock),
  {ok, {IP, _Port}} = inet:peername(ClientSocket),
  tcp_server_supervisor:start_child(),
  {noreply, State#state{socket = ClientSocket, addr = IP}};

handle_info(_Info, StateData) ->
  {noreply, StateData}.

terminate(_Reason, #state{socket = Socket}) ->
  (catch gen_tcp:close(Socket)),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.