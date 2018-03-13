-module(p04).
-export([len/1]).

len(H) ->
    len(H, 0).

len([Head|Tail],N) ->
    len(Tail, N+1);

len([], N) -> 
    N.