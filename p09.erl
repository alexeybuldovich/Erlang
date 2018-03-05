-module(p09).
-export([pack/1]).


pack([]) ->
    [];
    
pack([H|[]]) ->
   %io:format("pack([H|[]]): H=~p; ~n", [H]),
   [H];

pack([H|T]) ->
    pack(T, [H], []).

pack([], Temp, Acc) ->
    %io:format("pack([], Temp, Acc): Temp=~p; Acc=~p; ~n", [Temp,Acc]),
    lists:reverse([Temp|Acc]);

pack([H|T], Temp, Acc) when H == hd(Temp) ->
    %io:format("~n pack([H|T], Temp, Acc) when H == hd(Temp): H=~p; T=~p; Temp=~p; Acc=~p; ~n",[H,T,Temp,Acc]),
    pack(T, [H|Temp], Acc);

pack([H|T], Temp, Acc) ->    
    %io:format("~n pack([H|T], Temp, Acc): H=~p; T=~p; Temp=~p; Acc=~p; ~n", [H,T,Temp,Acc]),
    pack(T, [H], [Temp|Acc]).
