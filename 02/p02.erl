-module(p02).
-export([find_last/1]).

find_last([A,B|[]]) ->
    [A,B];

find_last([_|T]) ->
    find_last(T).