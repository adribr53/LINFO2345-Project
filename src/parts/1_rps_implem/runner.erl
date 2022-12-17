#!/usr/bin/env escript
-mode(compile).
-export([main/1]).

gen_nodes(0, Cluster, _, _, _, _) 							-> Cluster;
gen_nodes(Cur, Cluster, N, ViewSize, SubsetSize, Logger) 	->
	Node = node:init(Cur, N, ViewSize, SubsetSize, Logger),
	%io:format("Node ~p created\n", [Cur]),
    gen_nodes(Cur - 1, [Node | Cluster], N, ViewSize, SubsetSize, Logger).

kill_after(N, Time) ->	
	PidToKill = list_to_atom(integer_to_list(N)),
	timer:send_after(Time, PidToKill, stop).

keep_alive(WaitTime) ->
	timer:sleep(list_to_integer(WaitTime)),
	end_keep_alive.

start(IN_N_NODE, IN_VIEW_FRAC, IN_SUBSET_FRAC, LOG_FILE) ->
	N_NODE = list_to_integer(IN_N_NODE),
	VIEW_FRAC = list_to_float(IN_VIEW_FRAC),
	SUBSET_FRAC = list_to_float(IN_SUBSET_FRAC),
	ViewSize = round(N_NODE*VIEW_FRAC),
	SubsetSize = round(N_NODE*SUBSET_FRAC),

	Logger = log:init(LOG_FILE),
	gen_nodes(N_NODE, [], N_NODE, ViewSize, SubsetSize, Logger),
	kill_after(rand:uniform(N_NODE), 50*8000),
	end_init.

main([IN_N_NODE, IN_VIEW_FRAC, IN_SUBSET_FRAC, LOG_FILE, WAIT_TIME]) ->
	start(IN_N_NODE, IN_VIEW_FRAC, IN_SUBSET_FRAC, LOG_FILE),
	keep_alive(WAIT_TIME).