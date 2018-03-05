-module(p03).
-export([but_last/2]).

but_last([H|_], 1) ->
    H;

but_last([H|T],N) ->
    but_last(T, N-1);

but_last([],_) -> 
    undefined.