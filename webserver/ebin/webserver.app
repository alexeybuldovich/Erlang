{application, 'webserver', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['cache_server','toppage_handler','webserver_app','webserver_sup']},
	{registered, [webserver_sup]},
	{applications, [kernel,stdlib,cowboy,jsx]},
	{mod, {webserver_app, []}},
	{env, []}
]}.