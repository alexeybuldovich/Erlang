-module(bs02).
-export([words/1]).

words(List) ->
    words(List, <<>>).
    
words(<<X,RestString/binary>>, Acc) when X /= 32 ->
    io:format("1: X=~w; RestString=~p; Acc=~p; ~n", [X,RestString,Acc]),
    words(RestString, <<Acc/binary,X>>);
    
words(<<X, RestString/binary>>, Acc) when X =:= 32 ->
    %Res1 = [Res, binary:bin_to_list(Acc, length(Acc))],
    io:format("2: X=~w; RestString=~p; Acc=~p; ~n", [X,RestString,Acc]),
    [Acc, words(RestString, <<>>)];
    
            
words(<<"",RestString/binary>>, Acc) ->
    io:format("3: RestString=~p; Acc=~p; ~n", [RestString,Acc]),
    Acc.