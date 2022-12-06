-module(node).
-compile(export_all).

exec(State) -> 
	receive
		view ->   
            io:format("having a view ~p\n", [State]),
			exec(State+1);
		period ->
			timer:send_after(3000, period),
            io:format("having a period ~p\n", [State]),
			exec(State)
	end.

period(Pid) ->
	Pid ! period.	

init_view() -> 
	io:format("init_view \n", []),
	N = 100, 
	P = 0.1, 
	Numbers = lists:seq(1, N),
	RandomNumbers = [rand:uniform() || _ <- Numbers],
	SortedRandomNumbers = lists:sort(RandomNumbers),
	NumToSample = trunc(N * P),
	Sample = lists:take(NumToSample, SortedRandomNumbers),
	io:format("Sample of ~p numbers: ~p~n", [NumToSample, Sample]),
	Sample.

start_nodes(0, Cluster) -> Cluster;
start_nodes(N, Cluster) ->
    Node = list_to_atom(lists:concat(["n", N])),
	NodePid = spawn(?MODULE, exec, [Node]),
	register(Node, NodePid),
	period(NodePid),
    start_nodes(N - 1, [Node | Cluster]).

main() ->
	start_nodes(5,[]),
    timer:send_interval(300, lists:concat(["n", 1]), view).	