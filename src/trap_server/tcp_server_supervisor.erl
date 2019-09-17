%%%-------------------------------------------------------------------
%%% @author 75195
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 九月 2019 22:48
%%%-------------------------------------------------------------------
-module(tcp_server_supervisor).
-behaviour(supervisor).
-export([start_link/1, start_child/1]).
-export([init/1]).
%% 服务器自己的进程监督
start_link(Port) ->
  io:format("TCP supvisor start link ~n"),
  supervisor:start_link({local, ?MODULE}, ?MODULE, [Port]).

%% 子进程监督器，用来监控连接进来的TCP客户端
start_child(LSock) ->
  io:format("TCP supervisor start child process ~n"),
  supervisor:start_child(tcp_client_supervisor, [LSock]).

init([tcp_client_supervisor]) ->
  io:format("TCP supervisor init client ~n"),
  {ok,
    {{simple_one_for_one, 0, 1},
      [
        {tcp_server_handler,
          {tcp_server_handler, start_link, []},
          temporary,
          brutal_kill,
          worker,
          [tcp_server_handler]
        }
      ]
    }
  };

init([Port]) ->
  io:format("TCP server supervisor init~n"),
  {ok,
    {{one_for_one, 5, 60},
      [
        % client supervisor
        {tcp_client_supervisor,
          {supervisor, start_link, [{local, tcp_client_supervisor}, ?MODULE, [tcp_client_supervisor]]},
          permanent,
          2000,
          supervisor,
          [tcp_server_listener]
        },
        % tcp listener
        {tcp_server_listener,
          {tcp_server_listener, start_link, [Port]},
          permanent,
          2000,
          worker,
          [tcp_server_listener]
        }
      ]
    }
  }.