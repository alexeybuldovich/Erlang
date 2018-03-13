-module(p11).
-export([encode_modified/1]).

encode_modified([]) ->
    [];
encode_modified([H|T]) ->
    encode_modified(T,H,1,[]).

encode_modified([],Prev,Count,Acc) -> 
    lists:reverse([[Count,Prev]|Acc]);
encode_modified([H|T],Prev,Count, Acc) when H == Prev->
    encode_modified(T,Prev,Count+1,Acc);
encode_modified([H|T],Prev,Count,Acc) when Count > 1->
    encode_modified(T,H,1,[[Count,Prev]|Acc]);
encode_modified([H|T],Prev,_Count,Acc) ->
encode_modified(T,H,1,[Prev|Acc]).