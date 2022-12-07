-module(node).
-compile(export_all).

exec(View, SubsetSize) -> 
	receive
		view ->   
			% respond to views sent
            io:format("having a view ~p\n", [View]),
			exec(View, SubsetSize);
		period ->
			% OK : find oldest node Q 
			% select SubsetSize-1 other nodes, update view (set to 0)
			% send them to Q
			% wait for Q's response (timeout ?)
			% update
			timer:send_after(3000, period),
            io:format("having a period ~p\n", [View]),
			exec(inc(View), SubsetSize)
	end.

period(Pid) ->
	Pid ! period.	

inc([{N, C}|T]) ->
	[{N, C+1}|inc(T)];
inc([]) -> 
	[].

% to test : node:oldest(-1, -1, [{'77',1},{'26',1},{'51',1},{'36',1},{'66',1},{'48',3},{'54',1},{'6',3},{'33',1},{'81',1}]).
oldest(CurOldest, OldestAge, [{Candidate, Age}|T]) ->
	case OldestAge>Age of 
		true ->
			oldest(CurOldest, OldestAge, T);
		false -> 
			oldest(Candidate, Age, T)
	end;
oldest(CurOldest, OldestAge, []) ->
	CurOldest.
% https://stackoverflow.com/questions/10318156/how-to-create-a-list-of-1000-random-numbers-in-erlang
init_view(N, Id) -> 
	make_view(N div 10, [], N,  list_to_atom(integer_to_list(Id)),  list_to_atom(integer_to_list(rand:uniform(N)))).

make_view(0, CurList, N, Id, Candidate) -> CurList;
make_view(R, CurList, N, Id, Candidate) ->	
	case Id==Candidate of 
	true ->
		make_view(R, CurList, N, Id, list_to_atom(integer_to_list(rand:uniform(N))) );
	false ->
		case lists:member({Candidate,0}, CurList) of
		true ->
			make_view(R, CurList, N, Id, list_to_atom(integer_to_list(rand:uniform(N))) );			
		false ->			
			make_view(R-1, [{Candidate,0} | CurList], N, Id, list_to_atom(integer_to_list(rand:uniform(N))))
		end
	end.

start_nodes(0, Cluster, N) -> Cluster;
start_nodes(Cur, Cluster, N) ->
    Node = list_to_atom(integer_to_list(Cur)),
	NodePid = spawn(?MODULE, exec, [init_view(N, Cur), N div 20]),
	register(Node, NodePid),
	period(NodePid),
    start_nodes(Cur - 1, [Node | Cluster], N).

main() ->
	start_nodes(100, [], 100),
    %timer:send_interval(300, list_to_atom(integer_to_list(rand:uniform(5))), view),
	ok.
