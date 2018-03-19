-module(test).
-compile(export_all).
%-export([add/2]).
 
add(Key,Value) -> 
    TC = get_timestamp(),
    ets:insert(table1, {key, value, time}).

    Key + Value.

get_timestamp() ->                                                                                                                                                                                   
  {Mega, Seconds, MilliSeconds} = erlang:timestamp(),
  (Mega*1000000 + Seconds)*1000 + erlang:round(MilliSeconds/1000).