-module(p05).
-export([reverse/1]).

reverse([Head|Tail]) ->
    [reverse(Tail)|Head],
    io:format("~p, ", [Head]);
    
reverse([]) ->
    [].