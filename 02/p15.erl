-module(p15).
-export([replicate/2]).

replicate([],_N)->
    [];
replicate(L,N) ->
    replicate(L,N,[]).

replicate([],_N,Acc) ->
    lists:reverse(Acc);
replicate([H|T],N,Acc) ->
    replicate(T,N, [timesof(N,H)| Acc]).
    
timesof(Number,Char) ->
    timesof(Number,Char,[]).
timesof(Number,Char,Acc) when Number > 0 ->
    timesof(Number-1,Char,[Char|Acc]);
timesof(_Number,_Char,Acc) ->
    Acc.    
    
