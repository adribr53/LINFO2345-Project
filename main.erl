-module(main).
-compile(export_all).

gen_nodes(0, Cluster, _, _, _) 						-> Cluster;
gen_nodes(Cur, Cluster, N, ViewSize, SubsetSize) 	->
	Node = node:init(Cur, N, ViewSize, SubsetSize),
	io:format("Node ~p created\n", [Cur]),
    gen_nodes(Cur - 1, [Node | Cluster], N, ViewSize, SubsetSize).

kill_after(N, Time) ->	
	PidToKill = list_to_atom(integer_to_list(N)),
	timer:send_after(Time, PidToKill, stop).

start() ->
	N_NODE = 100, % 1000
	VIEW_FRAC = 0.1, % 0.2
	SUBSET_FRAC = 0.05, % 0.1
	ViewSize = round(N_NODE*VIEW_FRAC),
	SubsetSize = round(N_NODE*SUBSET_FRAC),
	gen_nodes(N_NODE, [], N_NODE, ViewSize, SubsetSize),
	log:create_file(),
	kill_after(rand:uniform(N_NODE), 50*8000),
	%timer:sleep(20000),
	ok.