-module(bs03_5).
-export([split/2]).

split(Bin, Chars) ->
    split(Bin, Chars, 0, []).
    
split(Bin, Chars, Idx, Acc) ->
    case Bin of 
        <<This:Idx/binary, Char, Tail/binary>> ->
            case lists:member(Char, Chars) of 
                false ->
                    split(Bin, Chars, Idx+1, Acc);
                true -> 
                    split(Tail, Chars, 0, [This|Acc])
            end;
        <<This:Idx/binary>> ->
            Result = lists:reverse(Acc, [This]),
            
            %Remove empty elements
            [Res || Res <- Result, Res /= <<>>]
    end.
            
            
            
    
    