{application, tcp_server,
  [{description, "TCP Server"},
    {vsn, "1.0.0"},
    {modules, [tcp_server, tcp_server_app, tcp_server_handler,
      tcp_server_listener, tcp_server_sup]},
    {registered, []},
    {mod, {tcp_server_app, []}},
    {env, []},
    {applications, [kernel, stdlib]}]}.