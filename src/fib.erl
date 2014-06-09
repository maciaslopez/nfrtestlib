%%% @author Macías López <macias.lopez@udc.es>
%%% @copyright (C) 2014, macias
%%% @doc
%%% Fibonacci module
%%% @end
%%% Created :  7 Jun 2014 by Macías López

-module(fib).
-compile(export_all).

fib(0) ->
    1;
fib(1) ->
    1;
fib(N) when N > 1 ->
    fib(N-1) + fib(N-2).


