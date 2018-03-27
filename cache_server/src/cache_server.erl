-module(cache_server).
%-export([export_all]).
-compile([export_all]).
%-define(TABLE_NAME, "table1").

child_start() ->
    receive 
        {ping, Pid} ->
            Pid ! pong;
        {lookup, Key} -> 
            child_lookup(Key)
            
end.    

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
    Pid ! {ping, self()},
    io:format("I (parent) have Pid: ~p~n", [self()]),
    io:format("I have a linked child: ~p~n", [Pid]),
    {ok, Pid}.
    %start_link_receive().
    
start_link_receive() ->
    receive
        Msg -> io:format("Child started: ~p~n", [Msg])
    end.


%lookup() ->
%    Pid ! {ping, self()}.
    
    
    

delete() ->
    ets:delete(table1).
    
get_timestamp() ->                                                                                                                                                                                   
  {Mega, Seconds, MilliSeconds} = erlang:timestamp(),
  (Mega*1000000 + Seconds)*1000 + erlang:round(MilliSeconds/1000).

