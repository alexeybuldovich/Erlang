-module(bs03).
-export([split/1]).

split(List) ->
    Splitter = "=:=",
    split(List, <<>>, [], Splitter).
    

%split(List, splitter) ->
%    split(List, <<>>, [], splitter).
    
%words(List) ->
%    words(List, <<>>, []).
    
split(<<X,RestString/binary>>, Acc, Res, splitter) when X /= 32 ->
    %io:format("1: X=~w; RestString=~p; Acc=~p; ~n", [X,RestString,Acc]),
    split(RestString, <<Acc/binary,X>>, Res, splitter);
    
split(<<X, RestString/binary>>, Acc, Res, splitter) when X =:= 32 ->
    %Res1 = [Res, binary:bin_to_list(Acc, length(Acc))],
    io:format("2: X=~w; RestString=~p; Acc=~p; ~n", [X,RestString,Acc]),
    split(RestString, <<>>, [Res,Acc], splitter);
    
            
split(<<"",RestString/binary>>, Acc, Res, splitter) ->
    io:format("3: RestString=~p; Acc=~p; Res=~p; ~n", [RestString,Acc,Res]),
    [Res,Acc].

%bite_size
