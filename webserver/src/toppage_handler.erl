%% Feel free to use, reuse and abuse the code in this file.

%% @doc webserver handler.
-module(toppage_handler).

-export([start_link/1, insert/3, lookup/1, lookup_all/0, lookup_by_date/2, child_delete_expired/0, delete_expired/0, stop/0, loop/1]).
-define(TABLE_NAME, table1).
-define(PID, msg).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
    %Method = cowboy_req:method(_Type),
    %io:format("~n Method: ~p; ~n", [Method]),
    %Req1 = maybe_echo(Method, Req),
	{ok, Req, undefined}.



handle(Req, State) ->

    %cache_server:start_link()

    %io:format("FirstReq = ~p~n", [Req]),

    {ok, Body, Req2} = cowboy_req:body(Req),

    %io:format("~n Body: ~p; Req2: ~p; ~n", [Body, Req2]),
    Body_decode = jsx:decode(Body),
    %io:format("~n Body: ~p; ~n",[Body_decode]),

    %Body_keys_list = proplists:get_keys(Body_decode),
    %io:format("~n Body_keys_list: ~p; ~n", [Body_keys_list]),

    Action_value = proplists:get_value(<<"action">>, Body_decode),
    %io:format("~n Action_value: ~p; ~n", [Action_value]),



    Result = case Action_value of
        <<"insert">> ->

            start_link({drop_interval, 3600}),

            Key = proplists:get_value(<<"key">>, Body_decode),
            %io:format("~n Key: ~p; ~n", [Key]),

            Value = proplists:get_value(<<"value">>, Body_decode),
            %io:format("~n Value: ~p; ~n", [Value]),

            insert(Key, Value, 120);

            %io:format("~n <<insert>> Result: ~p;  ~n", [Result]);

        <<"lookup">> ->
            Key = proplists:get_value(<<"key">>, Body_decode),
            lookup(Key);

        <<"lookup_by_date">> ->
            %io:format("~n lookup_by_date ~n"),

            DateFrom = proplists:get_value(<<"date_from">>, Body_decode),
            %io:format("~n DateFrom: ~p; ~n", [DateFrom]),

            DateTo = proplists:get_value(<<"date_to">>, Body_decode),
            %io:format("~n DateTo: ~p; ~n", [DateTo]),

            lookup_by_date(DateFrom, DateTo);

        <<"lookup_all">> ->
                lookup_all();

        <<"start_link">> ->
            start_link({drop_interval, 3600})

    end,

    %io:format("~n After case: ~n"),


    %Method = cowboy_req:method(Req),
    %Param = cowboy_http_req:qs_val(<<"POST">>, Req),

    
    %{Method1, Req1} = cowboy_req:method(Req),
    %io:format("~n Req1: ~p; Method1: ~p; ~n", [Req1, Method1]),

    %Handler0 = proplists:get_value(<<action>>, State),
    %io:format("~n Handler0: ~p; ~n", [Handler0]),

    %QsVals = cowboy_req:parse_qs(Req),
    %{_, Lang} = lists:keyfind(<<"action">>, 1, QsVals),
    %io:format("~n Lang: ~p; ~n",[Lang]),

    %{FormData, Req0} = cowboy_http_req:body_qs(Req),
    %io:format("~n Req0: ~p; FormData: ~p; ~n", [Req0, FormData]),

    %Val = cowboy_http_req:qs_val(<<"localhost">>, Req),
    %io:format("~n Val = ~p; ~n", [Val]),

    %{Method, Req2}       = cowboy_req:method(Req),
    %io:format("~n Method: ~p; Req2: ~p; ~n", [Method, Req2]),

    %{FwdIPRaw, Req3}     = cowboy_req:header(<<"x-forwarded-for">>, Req2),
    %io:format("~n FwdIPRaw: ~p; Req3: ~p ~n",[FwdIPRaw, Req3]),

    %{_, Req4} = cowboy_req:cookie(<<"cook">>, Req3),
    %io:format("~n Req4: ~p; ~n", [Req4]),



    %{_, Values} = cowboy_req:qs_vals(Req4),
    %io:format("~n Values: ~p; ~n", [Values]),


    %Res_json = jsx:encode([{<<"library">>,<<"jsx">>},{<<"awesome">>,true}]),

    %io:format("~n Result: ~p; ~n",[Result]),

    Res_json = jsx:encode([{<<"result">>, Result}]),

    %io:format("~n Res_json: ~p; ~n", [Res_json]),

    %start_link({drop_interval,3600}),

	{ok, Req2} = cowboy_req:reply(200, [
		{<<"content-type">>, <<"application/json">>}
	], Res_json, Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.





start_link({_, Interval}) ->
    TimeExpire = get_timestamp() + Interval * 1000,
	  Pid = spawn(toppage_handler, loop, [TimeExpire]),
    register(?PID, Pid),
    Pid ! {start, self()},
    get_response(),

    insert(<<"Key1">>, <<"Value1">>, 120),
    insert(<<"Key2">>, <<"Value2">>, 140),
    insert(<<"Key3">>, <<"Value3">>, 1600),

    {ok, Pid}.

    %io:format("~n ~p, ~p, ~p; ~n", [DropInterval, Interval, TimeExpire]).




insert(Key, Value, Interval) ->
    %io:format("~n insert Key: ~p; Value: ~p; Interval: ~p; ~n", [Key, Value, Interval]),
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
    %io:format("~n DateFrom: ~p; DateTo: ~p; ~n", [DateFrom, DateTo]),
    %io:format("~n to_timestamp: ~p ~n",(calendar:datetime_to_gregorian_seconds(DateFrom) - 62167219200)*1000),

    <<YearFrom:4/binary, _:1/binary, MonthFrom:2/binary, _:1/binary,  DayFrom:2/binary, _:1/binary, HoursFrom:2/binary, _:1/binary, MinutesFrom:2/binary, _:1/binary, SecondsFrom:2/binary>> = DateFrom,
    <<YearTo:4/binary, _:1/binary, MonthTo:2/binary, _:1/binary,  DayTo:2/binary, _:1/binary, HoursTo:2/binary, _:1/binary, MinutesTo:2/binary, _:1/binary, SecondsTo:2/binary>> = DateTo,

    %io:format("~n DateFrom: ~p; DateTo: ~p; ~n", [{{Year,Month,Day}}, DateTo]),

    YearFrom2 = list_to_integer(binary:bin_to_list(YearFrom)),
    MonthFrom2 = list_to_integer(binary:bin_to_list(MonthFrom)),
    DayFrom2 = list_to_integer(binary:bin_to_list(DayFrom)),
    HoursFrom2 = list_to_integer(binary:bin_to_list(HoursFrom)),
    MinutesFrom2 = list_to_integer(binary:bin_to_list(MinutesFrom)),
    SecondsFrom2 = list_to_integer(binary:bin_to_list(SecondsFrom)),

    YearTo2 = list_to_integer(binary:bin_to_list(YearTo)),
    MonthTo2 = list_to_integer(binary:bin_to_list(MonthTo)),
    DayTo2 = list_to_integer(binary:bin_to_list(DayTo)),
    HoursTo2 = list_to_integer(binary:bin_to_list(HoursTo)),
    MinutesTo2 = list_to_integer(binary:bin_to_list(MinutesTo)),
    SecondsTo2 = list_to_integer(binary:bin_to_list(SecondsTo)),

    DateFrom2 = to_timestamp({{YearFrom2,MonthFrom2,DayFrom2},{HoursFrom2,MinutesFrom2,SecondsFrom2}}),
    DateTo2 = to_timestamp({{YearTo2,MonthTo2,DayTo2},{HoursTo2,MinutesTo2,SecondsTo2}}),


    %io:format("~n DateFrom2: ~p; DateTo2: ~p; ~n", [DateFrom2, DateTo2]),

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
        Msg;
        %jsx:encode([<<"result">>, Msg]);
			  %io:format("~n~p~n",[Msg]);
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
            %io:format("~nDateFrom: ~p; DateTo: ~p; ~n", [DateFrom, DateTo]),

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