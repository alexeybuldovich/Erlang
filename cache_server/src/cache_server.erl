-module(cache_server).
-compile([export_all]).
-include_lib("eunit/include/eunit.hrl").
-define(TABLE_NAME, "table1").

child_start() ->
    receive 
        {start, Pid} ->
            ets:new(table1, [public, named_table]);
        %    Pid ! pong;
        {insert, Key, Value, Interval, Pid} ->
            child_insert(key, Value, Interval),
            Pid ! insert;
        {lookup, Key} -> 
            child_lookup(Key)
            
end.    

child_insert(Key, Value, Time) ->
    TimeExpire = get_timestamp() + Time * 1000,
    ets:insert(?TABLE_NAME, {Key, Value, TimeExpire}).


child_lookup(Key) ->
    CurrentTime = get_timestamp(),
    
    Record = ets:lookup(table1, Key),

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


start_link() ->
    Pid = spawn_link(cache_server, child_start, []),
    link(Pid),
    Pid ! {start, self()},
    io:format("I (parent) have Pid: ~p~n", [self()]),
    io:format("I have a linked child: ~p~n", [Pid]),
    %start_link_receive(),
    {ok, Pid}.

    
start_link_receive() ->
    receive
        Msg -> io:format("Child started: ~p~n", [Msg])
    end.

insert(Pid, Key, Value, Interval) -> 
    Pid ! {insert, Key, Value, Interval, self()},
    start_link_receive().

%lookup() ->
%    Pid ! {ping, self()}.

delete() ->
    ets:delete(table1).
    
get_timestamp() ->                                                                                                                                                                                   
  {Mega, Seconds, MilliSeconds} = erlang:timestamp(),
  (Mega*1000000 + Seconds)*1000 + erlang:round(MilliSeconds/1000).

