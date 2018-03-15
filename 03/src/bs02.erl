-module(bs02).
-export([words/1]).
-include_lib("eunit/include/eunit.hrl").

words(List) ->
    words(List, <<>>).
    
words(<<X,RestString/binary>>, Acc) when X /= 32 ->
    words(RestString, <<Acc/binary,X>>);
    
words(<<X, RestString/binary>>, Acc) when X =:= 32 ->
    [Acc, words(RestString, <<>>)];
    
words(<<"",RestString/binary>>, Acc) ->
    Acc.



word_test_() -> [
    ?_assert(words(<<"Text with four words">>) =:= [<<"Text">>,[<<"with">>,[<<"four">>,<<"words">>]]])
].