-module(my_cache).
-export([create/0, insert/3, lookup/1, delete/0, get_timestamp/0]).
-include_lib("eunit/include/eunit.hrl").
-define(TABLE_NAME, table1).

create() ->
    ets:new(table1, [public, named_table]).
    
insert(Key, Value, Time) ->
    TimeExpire = get_timestamp() + Time * 1000,
    ets:insert(?TABLE_NAME, {Key, Value, TimeExpire}).
    
lookup(Key) ->
    CurrentTime = get_timestamp(),
    
    Record = ets:lookup(?TABLE_NAME, Key),

    case Record =:= [] of
    
        false -> 

            [{Key, Value, TimeExpire}] = Record,

            case TimeExpire >= CurrentTime of 
                true ->
                    Value;
                false ->
                    io:format("~n Time is out for current key ~n")
            end;

        true -> 
            io:format("~n Key is not found ~n")
        
    end.
    

delete() ->
    CurrentTime = get_timestamp(),
    ets:select_delete(?TABLE_NAME, [{{'$1', '$2', '$3'}, [{'<', '$3', CurrentTime}], [true]}]).
    
get_timestamp() ->                                                                                                                                                                                   
  {Mega, Seconds, MilliSeconds} = erlang:timestamp(),
  (Mega*1000000 + Seconds)*1000 + erlang:round(MilliSeconds/1000).

lookup_test_() ->
    [
        ?_assert(create() =:= table1),
        ?_assert(insert(key1, value1, 600) =:= true),
        ?_assert(lookup(key1) =:= value1),
        ?_assert(lookup(key3) =:= ok),
        ?_assert(delete() =:= true)
    ].