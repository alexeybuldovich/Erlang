-module(bs01).
-export([first_word/1]).
-include_lib("eunit/include/eunit.hrl").

first_word(List) ->
    first_word(List, <<>>).
    
first_word(<<X,RestString/binary>>, Acc) when X /= 32 ->
    first_word(RestString, <<Acc/binary,X>>);
    
first_word(<<" ", Rest/binary>>, Acc) ->
    Acc.



first_word_test_() -> [
    ?_assert(first_word(<<"Some text">>) =:= <<"Some">>),
    ?_assert(first_word(<<"aaa bbb ccc">>) =:= <<"aaa">>),
    ?_assert(first_word(<<"asd-zxc qwe-zxc">>) =:= <<"asd-zxc">>)
].