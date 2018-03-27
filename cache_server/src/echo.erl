-module(echo).
-export([go/0, insert/4, lookup/2, stop/1, loop/0]).

go() ->
	Pid = spawn(echo, loop, []),
	%Pid ! {self(), hello},
    Pid ! {start, self()},
	receive
		{Pid, Msg} ->
			io:format("P1 ~w~n",[Msg]);
        {Msg} ->
            io:format("~n Receive ~w~n", [Msg])
	end,
    {ok, Pid}.
	%Pid ! stop.

insert(Pid, Key, Value, Interval) ->
    Pid ! {insert, Pid, Key, Value, Interval}.

lookup(Pid, Key) ->
    Pid ! {lookup, Pid, Key}.


lookup_by_date(Pid, DateFrom, DateTo) -> 
    Pid ! {lookup_by_date, Pid, DateFrom, DateTo}.
    
stop(Pid) ->
    Pid ! stop.

loop() ->
	receive
        {start, Pid} -> 
            ets:new(table1, [public, named_table]),
            io:format("~nets:new~n"),
            Pid ! {self(), start_done},
			loop();
        {insert, Pid, Key, Value, Interval} -> 
            io:format("~nchild_insert(Key, Value, Interval):~n"),
            TimeExpire = get_timestamp() + Interval * 1000,
            ets:insert(table1, {Key, Value, TimeExpire}),
			loop();
        {lookup, Pid, Key} ->
            Value = child_lookup(Key),
            io:format("~n Lookup: ~p~n", [Key]),
            Pid ! {self(), Value},
            loop();
        {lookup_by_date, Pid, DateFrom, DateTo} -> 
            
            loop();
		{From, Msg} ->
			From ! {self(), Msg},
			loop();
		stop ->
            io:format("~nStop~n"),
			true
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


get_timestamp() ->                                                                                                                                                                                   
  {Mega, Seconds, MilliSeconds} = erlang:timestamp(),
  (Mega*1000000 + Seconds)*1000 + erlang:round(MilliSeconds/1000).
