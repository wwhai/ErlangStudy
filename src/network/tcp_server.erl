%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 八月 2019 12:42
%%%-------------------------------------------------------------------
-module(tcp_server).
-export([start_parallel_server/1]).
%%
-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).

-import(ets, [insert_new/2]).

%服务端
start_parallel_server(Port) ->
  %创建一个全局的ets表，存放客户端的id
  ets:new(clients_table, [ordered_set, public, named_table, {write_concurrency, true}, {read_concurrency, true}]),

  case gen_tcp:listen(Port, [binary, {packet, 0}, {active, true}]) of
    {ok, LocalHostPort} ->
      spawn(fun() -> listen(LocalHostPort) end);
    {error, Reason} ->
      io:format("~p~n", [Reason])
  end.

listen(LocalHostPort) ->
  case gen_tcp:accept(LocalHostPort) of
    {ok, Socket} ->
      %每连接到一个客户端，把id插入到ets表中
      case ets:last(clients_table) of
        '$end_of_table' ->
          ets:insert(clients_table, {1, Socket});
        Other ->
          ets:insert(clients_table, {Other + 1, Socket})
      end,
      loop(Socket),
      spawn(fun() -> listen(LocalHostPort) end);

    {error, Reason} ->
      io:format("Error : ~p~n", [Reason])
  end.

loop(Socket) ->
  receive
    {tcp, Socket, Bin} ->
      [ID, Msg] = binary_to_term(Bin),
      io:format("Messages is ~p~n", [Msg]),
      [{Id, ClientSocket}] = ets:lookup(clients_table, ID),
      gen_tcp:send(ClientSocket, term_to_binary(Msg)),
      loop(Socket);
    {tcp_closed, Socket} ->
      io:format("Server socket closed ~n")
  end.
