%% TCP Server Application (tcp_server_app.erl)
-module(otp_tcp_server).
-author('saleyn@gmail.com').

%% 实现application模式
-behaviour(application).

-export([start_client/0]).

%% 应用程序启动以及监控树回调函数
-export([start/2, stop/1, init/1]).

%% 宏变量定义
-define(MAX_RESTART,    5).
-define(MAX_TIME,      60).
-define(DEF_PORT,    2222).

%% 启动客户端进程的接口
%% 在监听程序建立连接时调用
start_client() ->
  %% 回调第二个init函数，因为第二个是动态添加监控树子节点
  %% 也就是说这里是两颗不同的监控树，使用了一个模块两个 init 函数来实现
  supervisor:start_child(tcp_client_sup, []).

%%----------------------------------------------------------------------
%% Application behaviour callbacks
%%----------------------------------------------------------------------
start(_Type, _Args) ->
  %% 获取端口配置参数，找不到时返回默认端口 ?DEF_PORT
  ListenPort = get_app_env(listen_port, ?DEF_PORT),

  %% 启动应用程序，回调函数为 第一个 init 函数，根据参数匹配，参数为 [端口，客户端回调模块]
  %% 第一个 init 函数仅仅是启动了两个监控树
  supervisor:start_link({local, ?MODULE}, ?MODULE, [ListenPort, tcp_echo_fsm]).

stop(_S) ->
  ok.

%%----------------------------------------------------------------------
%% Supervisor behaviour callbacks
%%----------------------------------------------------------------------
init([Port, Module]) ->
  {ok,
    %% 监控树策略参数，ono_for_one策略，设置MAX_TIME最多重启的MAX_RESTART次
    {_SupFlags = {one_for_one, ?MAX_RESTART, ?MAX_TIME},
      [
        % TCP Listener
        {   tcp_server_sup,                          % Id       = internal id
          {tcp_listener,start_link,[Port,Module]}, % StartFun = {M, F, A}
          permanent,                               % Restart  = permanent | transient | temporary
          2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
          worker,                                  % Type     = worker | supervisor
          [tcp_listener]                           % Modules  = [Module] | dynamic
        },
        % Client instance supervisor
        {
          %% Module参数初始化了tcp_client_sup监控树的 init 函数, init 函数在下面
          tcp_client_sup,
          %% 子节点启动策略
          {supervisor,start_link,[{local, tcp_client_sup}, ?MODULE, [Module]]},
          permanent,                               % Restart  = permanent | transient | temporary
          infinity,                                % Shutdown = brutal_kill | int() >= 0 | infinity
          supervisor,                              % Type     = worker | supervisor
          []                                       % Modules  = [Module] | dynamic
        }
      ]
    }
  };

%% 在服务器接收连接时，创建客户端进程时会回调到这个函数，使用simple_one_for_one启动策略
%%　参数 Module 在第一个
init([Module]) ->
  {ok,
    %% 另外一种根监督树模式，simple_one_for_one策略子节点只能动态添加
    {_SupFlags = {simple_one_for_one, ?MAX_RESTART, ?MAX_TIME},
      [
        % TCP Client
        {   undefined,                               % Id       = internal id
          {Module,start_link,[]},                  % StartFun = {M, F, A}
          temporary,                               % Restart  = permanent | transient | temporary
          2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
          worker,                                  % Type     = worker | supervisor
          []                                       % Modules  = [Module] | dynamic
        }
      ]
    }
  }.

%%----------------------------------------------------------------------
%% Internal functions
%%----------------------------------------------------------------------
%% 获取配置文件xxx.app文件中的配置变量
get_app_env(Opt, Default) ->
  case application:get_env(application:get_application(), Opt) of
    {ok, Val} -> Val;
    _ ->
      case init:get_argument(Opt) of
        [[Val | _]] -> Val;
        error       -> Default
      end
  end.