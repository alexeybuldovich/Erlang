-module(bs01).
-export([first_word/1]).

first_word(List) ->
    first_word(List, <<>>).
    
first_word(<<X,RestString/binary>>, Acc) when X /= 32 ->
    first_word(RestString, <<Acc/binary,X>>);
    
first_word(<<" ", Rest/binary>>, Acc) ->
    Acc.