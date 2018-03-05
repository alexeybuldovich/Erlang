-module(p13).
-export([decode/1]).


decode([])->
    [];

%decode([[1,X]|[]])->
%    [X];
%    
%decode([[2,X]|[]])->
%    [X,X];
%    
%decode([[N,X]|[]])->
%    [X|decode([[N-1,X]])];
%
%decode([[2,X]|T])->
%    [X|[X|decode(T)]];
%
%decode([[N,X]|T])->
%    [X|decode([[N-1,X]|T])];
%
%decode([H|[[N,X]|T]])->
%    [H|decode([[N,X]|T])];
%
%decode([H|[]])->
%    io:format("~n decode([H|[]])"),
%    [H].
    
decode(List)->
    decode(List, []).
    
decode([H|T], Acc) ->
    io:format("~n decode([H|T], Acc): H=~p; T=~p; Acc=~p; ~n", [H,T,Acc]),
    [H2|T2] = H,
    io:format("~n T2=~p; ~n", [T2]),
    decode2(T2, H2).
    
decode2(H, 0) ->
    [];
    
decode2(H, N) when N > 0 ->
    io:format("~n decode2(H, N) when N > 0: H=~p; N=~p; ~n", [H,N]),
    [H|decode2(H,N-1)].
    