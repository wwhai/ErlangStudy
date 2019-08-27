-module(tcp_parallel_server).
-define(TCP_OPT, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]).
-export([start_server/0]).

start_server() ->
  {ok, ListenSocket} = gen_tcp:listen(9999, ?TCP_OPT),
  spawn(fun() -> parallel_connect(ListenSocket) end).

parallel_connect(ListenSocket) ->
  case gen_tcp:accept(ListenSocket) of
    {ok, Socket} ->
      spawn(fun() -> parallel_connect(ListenSocket) end),
      loop_receive(Socket);
    {error, Reason} ->
      io:format("server accept socket error:~p~n",[Reason])
  end.

loop_receive(Socket) ->
  receive
    {tcp, Socket, Bin} ->
      io:format("server receive bin data:~p~n",[Bin]),
      UnpackData = binary_to_term(Bin),
      io:format("server receive data:~p~n",[UnpackData]),
      Reply = {reply, UnpackData},
      gen_tcp:send(Socket, term_to_binary(Reply)),
      loop_receive(Socket);
    {tcp_closed, Socket} ->
      io:format("server socket closed: ~p~n",[Socket])
  after 3000 ->
    io:format("server time out, close socket~n"),
    gen_tcp:close(Socket)
  end.