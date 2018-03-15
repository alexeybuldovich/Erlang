-module(bs03).
%-import(string, [len/1]).
-export([split/2]).
-include_lib("eunit/include/eunit.hrl").

split(Bin, Chars) ->
    split(Bin, Chars, <<>>).
    
split(<<X, RestString/binary>>, Chars, Acc) ->
    
    Str = <<X, RestString/binary>>,
    
    Len_str = byte_size(Str),
    Len_chars = byte_size(Chars),

    case Len_str >= Len_chars of

        true ->
            <<X2:Len_chars/binary, RestString2/binary>> = Str,

            case X2 =:= Chars of 
                true ->
                    split(RestString2, Chars, <<Acc/binary,",">>);
                false ->
                    split(RestString, Chars, <<Acc/binary,X>>)
            end;
        false ->
            split(RestString, Chars, <<Acc/binary,X>>)
        end;
    
split(<<>>, Chars, Acc) ->
    Acc.



split_test_() ->
    [?_assert(split(<<"Col1-:-Col2-:-Col3-:-Col4-:-Col5">>, <<"-:-">>) =:= <<"Col1,Col2,Col3,Col4,Col5">>),
     ?_assert(split(<<"111---111--222-333">>, <<"---">>) =:= <<"111,111--222-333">>),
     ?_assertException(error, function_clause, split(123, <<"-:-123">>))
].