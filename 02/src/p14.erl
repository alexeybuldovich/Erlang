-module(p14).
-export([duplicate/1]).



duplicate([])->
    [];
duplicate(L) ->
    duplicate(L,[]).

duplicate([],Acc) ->
    lists:reverse(Acc);
duplicate([H|T],Acc)->
duplicate(T,timesof(2,H) ++ Acc).

timesof(Number,Char) ->
    timesof(Number,Char,[]).
timesof(Number,Char,Acc) when Number > 0 ->
    timesof(Number-1,Char,[Char|Acc]);
timesof(_Number,_Char,Acc) ->
    Acc.