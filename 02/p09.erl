-module(p09).
-export([pack/1]).


pack([]) ->
    [];
    
pack([H|[]]) ->
   [H];

pack([H|T]) ->
    pack(T, [H], []).

pack([], Temp, Acc) ->
    lists:reverse([Temp|Acc]);

pack([H|T], Temp, Acc) when H == hd(Temp) ->
    pack(T, [H|Temp], Acc);

pack([H|T], Temp, Acc) ->    
    pack(T, [H], [Temp|Acc]).
