-module(p08).
-export([compress/1]).

compress([])->
    [];

compress(L)->
    compress(L,[]).

compress([H|[]], [H1|T1]) when H==H1 ->
    lists:reverse([H1|T1]);

compress([H|[]], Acc) ->
    lists:reverse([H|Acc]);

compress([H|T], [H1|T1]) when H==H1 ->
    compress(T, [H1|T1]);

compress([H|T], Acc) ->
    compress(T, [H|Acc]).


