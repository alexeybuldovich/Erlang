-module(p06).
-export([palindrom/1]).

palindrom(List) ->
    [H|T] = List,
    List_reverse = lists:reverse(List),
    
    Res = palindrom(List, List_reverse).
    
palindrom([H|T], [HR|TR]) ->
    
    case H == HR of
        true -> palindrom(T, TR);
        false -> false
    end;
    
    
palindrom([], []) -> 
    true.