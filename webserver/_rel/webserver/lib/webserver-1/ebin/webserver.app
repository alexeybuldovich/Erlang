%% Feel free to use, reuse and abuse the code in this file.

{application, webserver, [
	{description, "Cowboy webserver example."},
	{vsn, "1"},
	{modules, ['cache_server','toppage_handler','webserver_app','webserver_sup']},
	{registered, [webserver_sup]},
	{applications, [
		kernel,
		stdlib,
		cowboy,
		jsx
	]},
	{mod, {webserver_app, []}},
	{env, []}
]}.
