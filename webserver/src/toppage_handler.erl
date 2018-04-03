%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(toppage_handler).
%-include_lib("cache_server.hrl").
-import_all(cache_server).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
    Res_json = jsx:encode([{<<"library">>,<<"jsx">>},{<<"awesome">>,true}]),

    cache_server:test(),

	{ok, Req2} = cowboy_req:reply(200, [
		{<<"content-type">>, <<"text/plain">>}
	], Res_json, Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.
