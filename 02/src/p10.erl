-module(p10).
-export([encode/1]).

encode([])->
    [];
encode([H|T]) ->
    encode(T,H,1,[]).

encode([],Prev,Count,Acc) ->
    lists:reverse([[Count,Prev]|Acc]);
encode([H|T],Prev,Count,Acc) when H == Prev ->
    encode(T,Prev,Count+1,Acc);
encode([H|T],Prev,Count,Acc) ->
    encode(T,H,1,[[Count,Prev]|Acc]).
