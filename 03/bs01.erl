-module(bs01).
-export([first_word/1]).

first_word(List) ->
    first_word(List, <<>>).
    
first_word(<<X,RestString/binary>>, Acc) when X /= 32 ->
    %io:format("X=~w; RestString=~p; Acc=~p; ~n", [X,RestString,Acc]),
    first_word(RestString, <<Acc/binary,X>>);
    
first_word(<<" ", Rest/binary>>, Acc) ->
    %io:format("first_word(<<" ", Rest/binary>>, Acc): "),
    Acc.