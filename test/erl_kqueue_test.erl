-module(erl_kqueue_test).

-include_lib("eunit/include/eunit.hrl").

delete_test() ->
	file:write_file("foo", "bar"),
	P = erl_kqueue:start("foo"),
	receive
		{P, _} ->
			?assert(false)
	after
		100 ->
			?assert(true)
	end,
	file:write_file("foo", "barsoom"),
	receive
		{P, _} ->
			?assert(false)
	after
		100 ->
			?assert(true)
	end,
	file:delete("foo"),
	receive
		{P, changed} ->
			?assert(true)
	after
		100 ->
			?assert(false)
	end.

move_test() ->
	file:write_file("foo", "bar"),
	P = erl_kqueue:start("foo"),
	receive
		{P, _} ->
			?assert(false)
	after
		100 ->
			?assert(true)
	end,
	file:write_file("foo", "barsoom"),
	receive
		{P, _} ->
			?assert(false)
	after
		100 ->
			?assert(true)
	end,
	file:rename("foo", "bar"),
	receive
		{P, changed} ->
			?assert(true)
	after
		100 ->
			?assert(false)
	end.

crash_test() ->
	P = erl_kqueue:start("foo"),
	receive
		{P, error} ->
			?assert(true)
	after
		100 ->
			?assert(false)
	end.
