%%% @author Macías López <macias.lopez@madsgroup.org>
%%% @copyright (C) 2013, Macías López
%%% @doc 
%%% Performance requirements test library for PBT tools.
%%% @end
%%% Created : 20 Nov 2013 by Macías López <macias.lopez@madsgroup.org>

-module(perf_eqc).

-include_lib("eqc/include/eqc.hrl").
%-include_lib("proper/include/proper.hrl").

-export([prop_simple_performance/2, prop_avg_performance/3]).

%%-----------------------------------------------------------------------------
%% Properties
%%-----------------------------------------------------------------------------

%% @doc Executes `N' times the function `F' in the module `M'
%% and checks that the average latency time of all calls is less than
%% `TimeLimit' (expressed in ms).
-spec prop_avg_performance(MF::{module(), atom(), eqc:generator()}, pos_integer(), pos_integer()) -> 
                                  eqc:property() | proper:outer_test(). 
prop_avg_performance({M,F,ArgGen}, N, TimeLimit) ->
     ?FORALL(Arg, ArgGen,
             ?FORALL(Ts, run_ntimes({?MODULE, response_time, [M,F,tuple_to_list(Arg)]}, N),
                     begin
                         AvgTime = avg(Ts),
                       %  format_time(AvgTime),
                         ?WHENFAIL(format_time(AvgTime),
                               AvgTime < TimeLimit)
                     end)).
                    
            
%% @doc Executes the function `F' in the module `M' and checks
%% that latency of each call is less than `TimeLimit' (expressed in ms).
-spec prop_simple_performance(MF::{module(), atom(), eqc:generator()}, pos_integer()) -> 
                                    eqc:property() | proper:outer_test().
prop_simple_performance({M,F,ArgGen}, TimeLimit) ->
    ?FORALL(Arg, ArgGen,
            begin
                Ms = response_time(M, F, tuple_to_list(Arg)),
                ?WHENFAIL(format_time(Ms),
                          Ms < TimeLimit)
            end).



%%-----------------------------------------------------------------------------
%% Fibonacci tests
%%-----------------------------------------------------------------------------

gcd(A,0) ->
    A;
gcd(A, B) ->
    gcd(B, A rem B).

large_nat() ->
    resize(40, nat()).

prop_fib() ->
    ?FORALL({A,B}, {large_nat(), large_nat()},
            gcd(fib:fib(A),fib:fib(B)) == fib:fib(gcd(A,B))).


%%-----------------------------------------------------------------------------
%% Util functions
%%-----------------------------------------------------------------------------

%% @doc Calculates the response time (i.e. latency) of the function `F' with
%% the arguments `A' in the module `M'.
-spec response_time(module(), atom(), [any()]) -> float().          
response_time(M,F,A) ->
    {Mc, _Val} = timer:tc(M,F,A),
    Mc/1000.

format_time(Ms) ->
    io:format("~p ms~n", [Ms]).

avg(L) ->
    sum(L) / length(L).

sum(L) ->
    lists:foldl(fun(X, Acc) -> X+Acc end, 0, lists:flatten(L)).


%% @doc Executes `N' times the function `F' with the arguments `A' in the module `M'
%%
%% The results of each execution are stored in a list.
-spec run_ntimes(MFA::{module(),fun(),[any()]}, pos_integer()) -> [any()].
run_ntimes(_, 0) ->
    [];
run_ntimes({M,F,A}, N) ->
  [apply(M,F,A)|run_ntimes({M,F,A},N-1)].
