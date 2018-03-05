-module(p08).
-export([compress/1]).




compress([])->
    [];

compress(L)->
    compress(L,[]).

compress([H|[]], [H1|T1]) when H==H1 ->
    %io:format("compress([H|[]], [H1|T1]): H=~p; H1=~p; T1=~p; ~n", [H, H1, T1]),
    lists:reverse([H1|T1]);

compress([H|[]], Acc) ->
    %io:format("compress([H|[]], Acc): H=~p; Acc=~p; ~n", [H,Acc]),
    lists:reverse([H|Acc]);

compress([H|T], [H1|T1]) when H==H1 ->
    %io:format("~n compress([H|T], [H1|T1]) when H==H1: H=~p; T=~p; H1=~p; T1=~p; ~n", [H,T,H1,T1]),
    compress(T, [H1|T1]);

compress([H|T], Acc) ->
    %io:format("~n compress([H|T], Acc): H=~p; T=~p; Acc=~p; ~n", [H,T,Acc]),
    compress(T, [H|Acc]).


%compress([H|[]]) ->
%    H;

%compress([H|T]) ->
%    [H2|T2] = T,
%    
%    case H =:= H2 of
%        true -> 
%            compress(T2);
%        false -> 
%            io:format("~p, ", [H]),
%            compress(T) 
%    end;
%    
%compress([]) ->
%    [].