-module(echo).
-export([start_link/1, insert/3, lookup/1, lookup_all/0, lookup_by_date/2, child_delete_expired/0, delete_expired/0, stop/1, loop/1]).
-define(TABLE_NAME, table1).
-define(PID, 0).

start_link([{DropInterval, Interval}]) ->

    TimeExpire = get_timestamp() + Interval * 1000,
	Pid = spawn(echo, loop, [TimeExpire]),

    register(?PID, Pid),

	%Pid ! {self(), hello},
    Pid ! {start, self()},
	%receive
	%	{Pid, Msg} ->
    %		io:format("P1 ~w~n",[Msg]);
    %    {Msg} ->
    %        io:format("~n Receive ~w~n", [Msg])
	%end,

    get_response(),

    insert("Key1", "Value1", 20),
    insert("Key2", "Value2", 30),
    insert("Key3", "Value3", 40),


    {ok, Pid}.
	%Pid ! stop.



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
    
    io:format("~n DateFrom: ~p; ~n", [DateFrom2]),
    io:format("~n DateTo: ~p; ~n", [DateTo2]),

    ?PID ! {lookup_by_date, self(), DateFrom2, DateTo2},
    
    get_response().
    
delete_expired() -> 
    ?PID ! {delete, self()},
    get_response().
    %{ok}.



stop(Pid) ->
    Pid ! stop.

get_response() ->
    io:format("~n get_response: ~n"),
    
	receive
		{?PID, Msg} ->
			io:format("~n~p~n",[Msg]);
        {Msg} ->
            io:format("~n Receive ~p~n", [Msg])
	end.

    %get_response().


loop(Drop_Interval) ->

    CurrentTime = get_timestamp(),

    %Delete expired records
    io:format("~n Delete expired records1: ~p; ~p ~n", [Drop_Interval, CurrentTime]),

    case Drop_Interval < CurrentTime of 
        true ->
            io:format("~n Delete expired records2: ~p; ~p ~n", [Drop_Interval, CurrentTime]),
            child_delete_expired();
        false -> 
            io:format("~n Delete expired records3: ~p; ~p ~n", [Drop_Interval, CurrentTime]),
            []
    end,

	receive
        {start, Pid} -> 
            ets:new(?TABLE_NAME, [public, named_table]),
            io:format("~nets:new~n"),
            Pid ! {self(), start_done},
			loop(Drop_Interval);
        {insert, Pid, Key, Value, Interval} -> 
            io:format("~nchild_insert(Key, Value, Interval):~n"),

            TimeExpire = get_timestamp() + Interval * 1000,
            io:format("~nTimeExpire: ~p~n", [TimeExpire]),

            ets:insert(?TABLE_NAME, {Key, Value, TimeExpire}),
            io:format("~nets:insert(table1, {~p, ~p, ~p}): ~n", [Key, Value, TimeExpire]),
    
            Pid ! {self(), insert_done},

			loop(Drop_Interval);
        {lookup, Pid, Key} ->
            Value = child_lookup(Key),
            %io:format("~n Lookup: ~p~n", [Key]),

            Pid ! {self(), Value},
            %io:format("~n Pid ! {self(), Value} ~n"),

            loop(Drop_Interval);
        {lookup_by_date, Pid, DateFrom, DateTo} -> 
            Res = ets:select(?TABLE_NAME, [{{'$1', '$2', '$3'}, [{'>=', '$3', DateFrom}, {'=<','$3',DateTo}], ['$$']}]),
            
            %Res = child_lookup_by_date(DateFrom, DateTo),
            Pid ! {self(), Res},
            loop(Drop_Interval);

        {lookup_all, Pid} ->
            io:format("~n lookup_all: ~n"),
            %Res = child_lookup_all(),

            Res = ets:tab2list(?TABLE_NAME),
            Pid ! {self(), Res},
            loop(Drop_Interval);

        {delete, Pid} ->
            child_delete_expired(),
            Pid ! {self(), delete_expired_done},
            loop(Drop_Interval);

        {delete} -> 
            delete_expired(),
            loop(Drop_Interval);
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

            %io:format("~n ~p >= ~p; ~n", [TimeExpire, CurrentTime]),

            case TimeExpire >= CurrentTime of 
                true ->
                    %io:format("~n Value: ~p; ~n", [Value]),
                    Value;
                false ->
                    io:format("~n Time is out for current key ~n")
            end;
        true -> 
            io:format("~n Key is not found ~n")
        
    end.


%child_lookup_all() ->
%        Res = ets:tab2list(?TABLE_NAME),
%        Res.

        %io:format("~n Res: ~p; ~n", [Res]).

        %case Res of 
        %[] ->
        %    Res1 = ets:first(?TABLE_NAME),
        %    io:format("~n Res1 = ets:first(?TABLE_NAME): ~n"),
        %    Record = ets:lookup(?TABLE_NAME, Res1),
        %    [{Key, Value, TimeExpire}] = Record,
        %    io:format("~n ~p;~p;~p; ~n", [Key, Value, TimeExpire]),
        %    child_lookup_all(Res1);
        %"$end_of_table" ->
        %    io:format("~n Res1 =:= '$end_of_table' ~n"),
        %    Res1 = false;
        %_ -> 
        %    Res1 = ets:next(?TABLE_NAME, Res),
        %    io:format("~n Res1 = ets:next(?TABLE_NAME, Res): ~n"),
        %    Record = ets:lookup(?TABLE_NAME, Res1),
        %    
        %    case Record =/= [] of 
        %        true ->
        %            io:format("~n Record: ~p~n: ", [Record]),
        %            [{Key, Value, TimeExpire}] = Record,
        %            io:format("~n ~p;~p;~p; ~n", [Key, Value, TimeExpire]),
        %            child_lookup_all(Res1);
        %        false -> 
        %            false
        %    end
    %end.



%child_lookup_by_date(DateFrom, DateTo) ->
%        io:format("~n child_lookup_by_date: ~p;~p;~n", [DateFrom, DateTo]),

%        ets:select(?TABLE_NAME, [{{'$1', '$2', '$3'}, [{'>=', '$3', DateFrom}, {'=<','$3',DateTo}], ['$$']}]).
        %io:format("~n Res: ~p; ~n", [Res]).

        %case Res of 
        %[] ->
        %    Res1 = ets:first(?TABLE_NAME),
        %    io:format("~n Res1 = ets:first(?TABLE_NAME): ~n"),
        %    Record = ets:lookup(?TABLE_NAME, Res1),
        %    [{Key, Value, TimeExpire}] = Record,
        %    io:format("~n ~p;~p;~p; ~n", [Key, Value, TimeExpire]),
        %    io:format("~n ~p >= ~p; ~p =< ~p; ~n", [TimeExpire, DateFrom, TimeExpire, DateTo]),

        %    case ((TimeExpire >= DateFrom) and (TimeExpire =< DateTo)) of 
        %        true ->
        %            child_lookup_by_date(Res1, DateFrom, DateTo, [Acc|Record]);
        %        false -> 
        %            child_lookup_by_date(Res1, DateFrom, DateTo, [Acc])
        %    end;
        %"$end_of_table" ->
        %    io:format("~n Res1 =:= '$end_of_table' ~n"),
        %    %Res1 = false;
        %    io:format("~nAcc2: ~p;~n", [Acc]),
        %    Acc;
        %_ -> 
        %    Res1 = ets:next(?TABLE_NAME, Res),
        %    io:format("~n Res1 = ets:next(?TABLE_NAME, Res): ~n"),
        %    Record = ets:lookup(?TABLE_NAME, Res1),
        %    
        %    case Record =/= [] of 
        %        true ->
        %            io:format("~n Record: ~p~n: ", [Record]),
        %            [{Key, Value, TimeExpire}] = Record,
        %            io:format("~n true ~p;~p;~p; ~n", [Key, Value, TimeExpire]),
        %            io:format("~n ~p >= ~p; ~p =< ~p; ~n", [TimeExpire, DateFrom, TimeExpire, DateTo]),


        %            case ((TimeExpire >= DateFrom) and (TimeExpire =< DateTo)) of 
        %                true ->
        %                    io:format("~n true ~n"),
        %                    child_lookup_by_date(Res1, DateFrom, DateTo, [Acc|Record]);
        %                false -> 
        %                    io:format("~n false ~n"),

        %                    child_lookup_by_date(Res1, DateFrom, DateTo, [Acc])
        %            end;

        %            %child_lookup_by_date(Res1, DateFrom, DateTo, [Acc|Record]);
        %        false -> 
        %            io:format("~nfalse Acc2: ~p;~n", [Acc]),
        %            Acc
        %    end


    %end.



child_delete_expired() ->
        io:format("~n child_delete_expired Res: ~n", []),

        CurrentTime = get_timestamp(),
        ets:select_delete(?TABLE_NAME, [{{'$1', '$2', '$3'}, [{'<', '$3', CurrentTime}], [true]}]).


get_timestamp() ->                                                                                                                                                                                   
  {Mega, Seconds, MilliSeconds} = erlang:timestamp(),
  (Mega*1000000 + Seconds)*1000 + erlang:round(MilliSeconds/1000).

to_timestamp({{Year,Month,Day},{Hours,Minutes,Seconds}}) ->
    (calendar:datetime_to_gregorian_seconds(
        {{Year,Month,Day},{Hours,Minutes,Seconds}}
    ) - 62167219200)*1000.