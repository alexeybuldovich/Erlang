-module(p06).
-export([palindrom/1]).

palindrom(List) ->
    [H|T] = List,
    List_reverse = lists:reverse(List),
    
    length(List),
    Res = palindrom(List, List_reverse),
    io:format("Res: ~p~n", [Res]).
    
palindrom([H|T], [HR|TR]) ->
    %io:format("~p; ~p; ~n", [T, TR]),
    
    case H == HR of
        true -> palindrom(T, TR);
        false -> false
    end;
    
    
palindrom([], []) -> 
    true.