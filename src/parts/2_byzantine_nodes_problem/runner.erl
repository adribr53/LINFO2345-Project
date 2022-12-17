#!/usr/bin/env escript
-mode(compile).
-export([main/1]).

gen_nodes(0, Cluster, _, _, _, _, _) 											-> Cluster;
gen_nodes(Cur, Cluster, N, ViewSize, SubsetSize, ByzantineNodesList, Logger) 	->
	case lists:any(fun(E) -> E == Cur end, ByzantineNodesList) of
		true 	-> 
			Node = byzantine:init(Cur, ByzantineNodesList, ViewSize, SubsetSize, Logger),
			%io:format("Byzantine Node ~p created\n", [Cur]),
	    	gen_nodes(Cur - 1, [Node | Cluster], N, ViewSize, SubsetSize, ByzantineNodesList, Logger);
		false 	-> 
			Node = node:init(Cur, N, ViewSize, SubsetSize, Logger),
			%io:format("Node ~p created\n", [Cur]),
		    gen_nodes(Cur - 1, [Node | Cluster], N, ViewSize, SubsetSize, ByzantineNodesList, Logger)
	end.

kill_after(N, Time) ->	
	PidToKill = list_to_atom(integer_to_list(N)),
	timer:send_after(Time, PidToKill, stop).

gen_rnd_nbr(0, _, ListId) 		-> ListId;
gen_rnd_nbr(N, Max, ListId) 	->
	GenNbr = rand:uniform(Max),
	case lists:any(fun(E) -> E == GenNbr end, ListId) of
		false 	-> gen_rnd_nbr(N-1, Max, [GenNbr|ListId]);
		true 	-> gen_rnd_nbr(N, Max, ListId)
	end.

keep_alive(WaitTime) ->
	timer:sleep(list_to_integer(WaitTime)),
	end_keep_alive.

start(IN_N_NODE, IN_BYZ_FRAC, IN_VIEW_FRAC, IN_SUBSET_FRAC, LOG_FILE) ->
	N_NODE = list_to_integer(IN_N_NODE), % 1000
	BYZ_FRAC = list_to_float(IN_BYZ_FRAC),
	VIEW_FRAC = list_to_float(IN_VIEW_FRAC), % 0.2
	SUBSET_FRAC = list_to_float(IN_SUBSET_FRAC), % 0.1
	N_BYZ_NODE = round(N_NODE*(BYZ_FRAC)+1),
	ViewSize = round(N_NODE*VIEW_FRAC),
	SubsetSize = round(N_NODE*SUBSET_FRAC),
	
	BYZ_NODE_ID = gen_rnd_nbr(N_BYZ_NODE, N_NODE, []),
	Logger = log:init(LOG_FILE),
	gen_nodes(N_NODE, [], N_NODE, ViewSize, SubsetSize, BYZ_NODE_ID, Logger),
	kill_after(rand:uniform(N_NODE), 50*8000),
	end_init.

main([IN_N_NODE, IN_BYZ_FRAC, IN_VIEW_FRAC, IN_SUBSET_FRAC, LOG_FILE, WAIT_TIME]) ->
	start(IN_N_NODE, IN_BYZ_FRAC, IN_VIEW_FRAC, IN_SUBSET_FRAC, LOG_FILE),
	keep_alive(WAIT_TIME).