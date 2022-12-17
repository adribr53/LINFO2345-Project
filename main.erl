-module(main).
-compile(export_all).

gen_nodes(0, Cluster, _, _, _, _, _) 											-> Cluster;
gen_nodes(Cur, Cluster, N, ViewSize, SubsetSize, ByzantineNodesList, Logger) 	->
	case lists:any(fun(E) -> E == Cur end, ByzantineNodesList) of
		true 	-> 
			Node = byzantine:init(Cur, ByzantineNodesList, ViewSize, SubsetSize, Logger),
			io:format("Byzantine Node ~p created\n", [Cur]),
	    	gen_nodes(Cur - 1, [Node | Cluster], N, ViewSize, SubsetSize, ByzantineNodesList, Logger);
		false 	-> 
			Node = node:init(Cur, N, ViewSize, SubsetSize, Logger),
			io:format("Node ~p created\n", [Cur]),
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

start() ->
	N_NODE = 100, % 1000
	BYZ_FRAC = 0.1,
	VIEW_FRAC = 0.1, % 0.2
	SUBSET_FRAC = 0.05, % 0.1
	LOG_FILE = "log.csv",

	% N_GOOD_NODE = round(N_NODE*(1-BYZ_FRAC)-1),
	N_BYZ_NODE = round(N_NODE*(BYZ_FRAC)+1),
	ViewSize = round(N_NODE*VIEW_FRAC),
	SubsetSize = round(N_NODE*SUBSET_FRAC),
	BYZ_NODE_ID = gen_rnd_nbr(N_BYZ_NODE, N_NODE, []),

	Logger = log:init(LOG_FILE),
	gen_nodes(N_NODE, [], N_NODE, ViewSize, SubsetSize, BYZ_NODE_ID, Logger),
	kill_after(rand:uniform(N_NODE), 50*8000),
	timer:sleep(20000),
	ok.