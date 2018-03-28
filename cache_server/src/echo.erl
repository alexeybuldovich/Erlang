-module(echo).
-export([go/0, insert/4, lookup/2, lookup_all/1, child_lookup_all/1, child_delete_expired/1, delete_expired/1, stop/1, loop/0]).
-define(TABLE_NAME, table1).


go() ->
	Pid = spawn(echo, loop, []),
	%Pid ! {self(), hello},
    Pid ! {start, self()},
	%receive
	%	{Pid, Msg} ->
    %		io:format("P1 ~w~n",[Msg]);
    %    {Msg} ->
    %        io:format("~n Receive ~w~n", [Msg])
	%end,

    get_response(),

    {ok, Pid}.
	%Pid ! stop.

insert(Pid, Key, Value, Interval) ->
    Pid ! {insert, self(), Key, Value, Interval},
    %get_response(),
    {ok}.

lookup(Pid, Key) ->
    Pid ! {lookup, self(), Key},
    get_response(),
    {ok}.

lookup_all(Pid) ->
    Pid ! {lookup_all, self()},
    get_response(),
    {ok}.

lookup_by_date(Pid, DateFrom, DateTo) -> 
    Pid ! {lookup_by_date, self(), DateFrom, DateTo}.
    
delete_expired(Pid) -> 
    Pid ! {delete, self()},
    get_response(),
    {ok}.



stop(Pid) ->
    Pid ! stop.

get_response() ->
    io:format("~n get_response: ~n"),
    
	receive
		{Pid, Msg} ->
			io:format("P1 ~w~n",[Msg]);
        {Msg} ->
            io:format("~n Receive ~w~n", [Msg])
	end.

    %get_response().


loop() ->
	receive
        {start, Pid} -> 
            ets:new(?TABLE_NAME, [public, named_table]),
            io:format("~nets:new~n"),
            Pid ! {self(), start_done},
			loop();
        {insert, Pid, Key, Value, Interval} -> 
            io:format("~nchild_insert(Key, Value, Interval):~n"),

            TimeExpire = get_timestamp() + Interval * 1000,
            io:format("~nTimeExpire: ~p~n", [TimeExpire]),

            ets:insert(?TABLE_NAME, {Key, Value, TimeExpire}),
            io:format("~nets:insert(table1, {~p, ~p, ~p}): ~n", [Key, Value, TimeExpire]),
    
            Pid ! {self(), insert_done},

			loop();
        {lookup, Pid, Key} ->
            Value = child_lookup(Key),
            io:format("~n Lookup: ~p~n", [Key]),

            Pid ! {self(), Value},
            io:format("~n Pid ! {self(), Value} ~n"),

            loop();
        {lookup_by_date, Pid, DateFrom, DateTo} -> 
            
            loop();

        {lookup_all, Pid} ->
            child_lookup_all([]),
            Pid ! {self(), lookup_all_done},
            loop();

        {delete, Pid} ->
            child_delete_expired([]),
            Pid ! {self(), delete_expired_done},
            loop();

		{From, Msg} ->
			From ! {self(), Msg},
			loop();
        {delete} -> 
            delete_expired([]);
            %loop();
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


child_lookup_all(Res) ->
        io:format("~n Res: ~p~n", [Res]),

        case Res of 
        [] ->
            Res1 = ets:first(?TABLE_NAME),
            io:format("~n Res1 = ets:first(?TABLE_NAME): ~n"),
            Record = ets:lookup(?TABLE_NAME, Res1),
            [{Key, Value, TimeExpire}] = Record,
            io:format("~n ~p;~p;~p; ~n", [Key, Value, TimeExpire]),
            child_lookup_all(Res1);
        "$end_of_table" ->
            io:format("~n Res1 =:= '$end_of_table' ~n"),
            Res1 = false;
        _ -> 
            Res1 = ets:next(?TABLE_NAME, Res),
            io:format("~n Res1 = ets:next(?TABLE_NAME, Res): ~n"),
            Record = ets:lookup(?TABLE_NAME, Res1),
            
            case Record =/= [] of 
                true ->
                    io:format("~n Record: ~p~n: ", [Record]),
                    [{Key, Value, TimeExpire}] = Record,
                    io:format("~n ~p;~p;~p; ~n", [Key, Value, TimeExpire]),
                    child_lookup_all(Res1);
                false -> 
                    false
            end


    end.

child_delete_expired(Res) ->
        io:format("~n Res: ~p~n", [Res]),

        case Res of 
        [] ->
            Res1 = ets:first(?TABLE_NAME),
            io:format("~n Res1 = ets:first(?TABLE_NAME): ~n"),
            Record = ets:lookup(?TABLE_NAME, Res1),
            [{Key, Value, TimeExpire}] = Record,
            io:format("~n ~p;~p;~p; ~n", [Key, Value, TimeExpire]),

            CurrentTime = get_timestamp(),

            case TimeExpire < CurrentTime of 
                true ->
                    io:format("~n TimeExpire < CurrentTime: (~p < ~p) ~n", [TimeExpire, CurrentTime]),
                    ets:delete(?TABLE_NAME, Key);
                false ->
                    io:format("~n TimeExpire >= CurrentTime: (~p >= ~p) ~n", [TimeExpire, CurrentTime]),
                    false
            end,

            child_delete_expired(Res1);
        "$end_of_table" ->
            io:format("~n Res1 =:= '$end_of_table' ~n"),
            Res1 = false;
        _ -> 
            Res1 = ets:next(?TABLE_NAME, Res),
            io:format("~n Res1 = ets:next(?TABLE_NAME, Res): ~n"),
            Record = ets:lookup(?TABLE_NAME, Res1),
            
            case Record =/= [] of 
                true ->
                    io:format("~n Record: ~p~n: ", [Record]),
                    [{Key, Value, TimeExpire}] = Record,
                    io:format("~n ~p;~p;~p; ~n", [Key, Value, TimeExpire]),

                    CurrentTime = get_timestamp(),

                    case TimeExpire < CurrentTime of 
                        true ->
                            io:format("~n TimeExpire < CurrentTime: (~p < ~p) ~n", [TimeExpire, CurrentTime]),
                            ets:delete(?TABLE_NAME, Key);
                        false ->
                            io:format("~n TimeExpire >= CurrentTime: (~p >= ~p) ~n", [TimeExpire, CurrentTime]),
                            false
                    end,

                    child_delete_expired(Res1);
                false -> 
                    false
            end


    end.

get_timestamp() ->                                                                                                                                                                                   
  {Mega, Seconds, MilliSeconds} = erlang:timestamp(),
  (Mega*1000000 + Seconds)*1000 + erlang:round(MilliSeconds/1000).
