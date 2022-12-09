-module(node).
-compile(export_all).

exec(View, SubsetSize, ExpectedNodes, Id) -> % Should subset size be adapted, were part of nodes to die ?
	receive
		{request, Subset, NodeId} ->   
			% respond to views sent
            io:format("receiving a view ~p\n", [View]),
			NodeId ! {response, sample([], View, SubsetSize, lists:nth(random:uniform(length(View))), {-1,0})},
			exec(View, SubsetSize, ExpectedNodes, Id);
		{response, Subset} ->
			% Remove entries pointing to P (-> {P,0})
			% lists:filter(fun ({Node,Age}) -> not lists:member(Elem, B) end, A ).
			lists:filter(fun ({Node,Age}) -> Node/=Id end, Subset ).

			% or already present entries in P's (-> {P, NP}) view from the subset send by Q. ()
			% Update P's view with the remaining entries commencing by empty entries of P (add {P1,N1})
			% and after by replacing entries sent to Q. (replace {P1,N1} by {P1,N2})
			exec(View, SubsetSize, ExpectedNodes, Id);
		period ->
			handle_period(View,SubsetSize,ExpectedNodes,Id,sample([], View, SubsetSize, lists:nth(random:uniform(length(View))), oldest(-1, -1, View)), oldest(-1, -1, View))
						
		{timeout, ToCheck} ->
			case  lists:member(ToCheck, ExpectedNodes) of 
				true -> % node did not respond in time, remove it of the view					
					exec(del_in_view(View, ToCheck), SubsetSize, del_in_expected(ExpectedNodes, ToCheck), Id);
				false ->
					exec(View, SubsetSize, del_in_expected(ExpectedNodes, ToCheck), Id)
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

% to test : node:sample([], [{'7',4},{'71',4}, {'25',4}], 2, {'71',4}).
sample(CurList, View, 0, Candidate, Oldest) -> 
	CurList;
sample(CurList, View, R, Candidate, Oldest) ->
	io:format("View : ~p ; CurList ~p\n", [View, CurList]),
	io:format("Lengths : ~p ; CurList ~p\n", [length(View), length(CurList)]),
	io:format("Lengths : ~p\n", [length(View)==length(CurList)]),
	case length(CurList)==length(View) of 
		true -> % in case view too small 
			CurList;
		false ->
			case lists:member(Candidate, CurList); Candidate==Oldest of 
				true ->
					sample(CurList, View, R, lists:nth(random:uniform(length(View)), View));
				false ->
					sample([Candidate|CurList], View, R-1, lists:nth(random:uniform(length(View)), View))
				end
		end.

% to test : node:reset_subset([{'7',4},{'71',4}, {'25',4}, {'78',4},{'22',4},{'42',4},{'73',4},{'58',4},{'15',4},{'3',4}], [{'42',4},{'73',4},{'22',4}], []).
reset_subset([{Node,Age}|T], ChosenOnes, NewView) -> 
	case lists:member({Node,Age}, ChosenOnes) of
		true ->
			reset_subset(T, ChosenOnes, [NewView|{Node,0}]);
		false ->
			reset_subset(T, ChosenOnes, [NewView|{Node,Age}])
		end;
reset_subset([], ChosenOnes, NewView) ->
	NewView.

handle_period(View, SubsetSize, ExpectedNodes, Id, Subset, Oldest) ->
	Oldest ! {request, Subset, Id}, % TODO : don't send counts ideally
	io:format("having a period ~p\n", [View]),
	timer:send_after(3000, period),
	timer:send_after(1000, {timeout, Oldest}),
	exec(inc(reset_subset(View, Subset, [])), SubsetSize, [Oldest | ExpectedNodes]);

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
	NodePid = spawn(?MODULE, exec, [init_view(N, Cur), N div 20, [], Node]),
	register(Node, NodePid),
	period(NodePid),
    start_nodes(Cur - 1, [Node | Cluster], N).

main() ->
	start_nodes(100, [], 100),
    %timer:send_interval(300, list_to_atom(integer_to_list(rand:uniform(5))), view),
	ok.
