-module(p13).
-export([decode/1]).

decode(List) ->
    decode(List, []).

decode([], Acc) ->
    Acc;

decode([H|T], Acc) ->
    [H1,T1]= H,
    Acc2 = decode2(H1, T1, []),
    Acc3 = lists:append(Acc, Acc2),
    decode(T, Acc3).
    
decode2(Count, Letter, Acc) when Count > 1 ->
    decode2(Count-1, Letter, [Letter|Acc]);

decode2(1, Letter, Acc) ->
    [Letter| Acc].

