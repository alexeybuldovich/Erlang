-module(cache_server).
-export([start_link/1, insert/3, lookup/1, lookup_all/0, lookup_by_date/2, child_delete_expired/0, delete_expired/0, stop/0, loop/1]).
-define(TABLE_NAME, table1).
-define(PID, msg).

start_link([{_, Interval}]) ->

    TimeExpire = get_timestamp() + Interval * 1000,
	Pid = spawn(cache_server, loop, [TimeExpire]),

    register(?PID, Pid),

    Pid ! {start, self()},

    get_response(),

    insert("Key1", "Value1", 20),
    insert("Key2", "Value2", 40),
    insert("Key3", "Value3", 600),


    {ok, Pid}.



insert(Key, Value, Interval) ->
    ?PID ! {insert, self(), Key, Value, Interval},
    get_response().
    %{ok}.

lookup(Key) ->
    ?PID ! {lookup, self(), Key},
    get_response().
    %{ok}.

lookup_all() ->
    ?PID ! {lookup_all, self()},
    get_response().
    %{ok}.

lookup_by_date(DateFrom, DateTo) -> 
    DateFrom2 = to_timestamp(DateFrom),
    DateTo2 = to_timestamp(DateTo),
    
    ?PID ! {lookup_by_date, self(), DateFrom2, DateTo2},
    
    get_response().
    
delete_expired() -> 
    ?PID ! {delete, self()},
    get_response().
    %{ok}.



stop() ->
    ?PID ! {stop, self()}.

get_response() ->
    
	receive
		{_, Msg} ->
			io:format("~n~p~n",[Msg]);
        {Msg} ->
            io:format("~n Receive ~p~n", [Msg])
	end.


loop(Drop_Interval) ->

    CurrentTime = get_timestamp(),

    %Delete expired records
    case Drop_Interval < CurrentTime of 
        true ->
            child_delete_expired();
        false -> 
            []
    end,

	receive
        {start, Pid} -> 
            ets:new(?TABLE_NAME, [public, named_table]),
            Pid ! {self(), start_done},
			loop(Drop_Interval);

        {insert, Pid, Key, Value, Interval} -> 
            TimeExpire = get_timestamp() + Interval * 1000,
            ets:insert(?TABLE_NAME, {Key, Value, TimeExpire}),
            Pid ! {self(), insert_done},
			loop(Drop_Interval);

        {lookup, Pid, Key} ->
            Value = child_lookup(Key),
            Pid ! {self(), Value},
            loop(Drop_Interval);

        {lookup_by_date, Pid, DateFrom, DateTo} -> 
            Res = ets:select(?TABLE_NAME, [{{'$1', '$2', '$3'}, [{'>=', '$3', DateFrom}, {'=<','$3',DateTo}], ['$$']}]),
            Pid ! {self(), Res},
            loop(Drop_Interval);

        {lookup_all, Pid} ->
            Res = ets:tab2list(?TABLE_NAME),
            Pid ! {self(), Res},
            loop(Drop_Interval);

        {delete, Pid} ->
            child_delete_expired(),
            Pid ! {self(), delete_expired_done},
            loop(Drop_Interval);

		{stop, Pid} ->
            %io:format("~nStop~n"),
            Pid ! {self(), stop_done},
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


child_delete_expired() ->
    CurrentTime = get_timestamp(),
    ets:select_delete(?TABLE_NAME, [{{'$1', '$2', '$3'}, [{'<', '$3', CurrentTime}], [true]}]).


get_timestamp() ->                                                                                                                                                                                   
  {Mega, Seconds, MilliSeconds} = erlang:timestamp(),
  (Mega*1000000 + Seconds)*1000 + erlang:round(MilliSeconds/1000).

to_timestamp({{Year,Month,Day},{Hours,Minutes,Seconds}}) ->
    (calendar:datetime_to_gregorian_seconds(
        {{Year,Month,Day},{Hours,Minutes,Seconds}}
    ) - 62167219200)*1000.