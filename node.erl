-module(node).
-compile(export_all).

exec(View, SubsetSize, ExpectedNodes, Id, Turn) -> % Should subset size be adapted, were part of nodes to die ?
	%%io:format("node ~p view : ~p\n", [Id,View]),
	% case length(View)==SubsetSize*2 of 
	% 	true ->
	% 		X=1;
	% 	false ->
	% 		io:format("~p : ~p\n", [Id, View])
	% 	end,
	% case Id=='1' of 
	% 	false ->
	% 		Y=1;
	% 	true ->
	% 		io:format("~p : ~p\n", [Id, View])
	% 	end,
	receive
		{request, ReqNodes, ReqNode} ->   			
			case length(View)==0 of
				true ->
					ReqNode ! {response, [], Id};
				false ->
					First = lists:nth(rand:uniform(length(View)), View),
					Subset = node:sample([], View, SubsetSize, First, {-1,0}),
					RespNodes = [Node || {Node, _} <- Subset],
					%%io:format("~p, request from ~p with subset ~p, respond with ~p\n", [Id, ReqNode, ReqNodes, RespNodes]),
					ReqNode ! {response, RespNodes, Id}
				end,			
			exec(View, SubsetSize, ExpectedNodes, Id, Turn);
		{response, RespNodes, RespNode} ->
			RespWithoutId = lists:filter(fun (Node) -> Node/=Id end, RespNodes ),
			ReqNodes = node:get_request_subset(RespNode, ExpectedNodes),	
			NewView = node:get_new_view(View, ReqNodes, RespWithoutId, SubsetSize*2),
			NewExpected = lists:filter(fun ({Node,_}) -> Node/=RespNode end, ExpectedNodes),
			logging(Id, View, Turn),
			exec(NewView, SubsetSize, NewExpected, Id, Turn);
		period ->
			NewView = inc(View),
			{Oldest, Age} = oldest(-1, -1, NewView),
			Subset = node:sample([], NewView, SubsetSize, {Oldest, Age}, {Oldest, Age}),
			ReqNodes = [Node || {Node, _} <- Subset],
			logging(Id, View, Turn),
			handle_period(NewView,SubsetSize,ExpectedNodes,Id,ReqNodes, Oldest, Turn+1);						
		{timeout, ToCheck} ->
			case  lists:member(ToCheck, [Node || {Node, _} <- ExpectedNodes]) of 
				true -> % node did not respond in time, remove it of the view	lists:filter(fun ({Node,_}) -> Node/=ToDel end, View).				
					NewView = del_in_view(View, ToCheck),
					NewExpected =  lists:filter(fun({Node,_}) -> Node/=ToCheck end, ExpectedNodes),
					exec(NewView, SubsetSize, NewExpected, Id, Turn);
				false ->%[[],[{'25',0},{'12',0},{'40',0},{'7',0},{'39',0}],2,{'39',0}]
					exec(View, SubsetSize, ExpectedNodes, Id, Turn)
			end
	end.

period(Pid) ->
	timer:send_after(3000, Pid, period). 

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
oldest(CurOldest, Age, []) ->
	{CurOldest, Age}.

sample(CurList, _, 0, _, _) -> % to test : node:sample([], [{'7',4},{'71',4}, {'25',4}], 2, {'71',4}). 
	CurList;
sample(CurList, View, R, Candidate, Oldest) ->
	case length(CurList)==length(View) of 
		true -> % in case view too small 
			CurList;
		false ->
			Next = lists:nth(rand:uniform(length(View)), View),
			case lists:member(Candidate, CurList) orelse Candidate==Oldest of 
				true ->
					sample(CurList, View, R, Next, Oldest);
				false ->
					sample([Candidate|CurList], View, R-1, Next, Oldest)
				end
		end.

reset_Q([{Node,Age}|T], Oldest, NewView) -> % to test : node:reset_subset([{'7',4},{'71',4}, {'25',4}, {'78',4},{'22',4},{'42',4},{'73',4},{'58',4},{'15',5},{'3',4}], {'15',5}, []). 
 	case Node==Oldest of
 		true ->
			(NewView ++ [{Node,0}]) ++ T;
 		false ->
 			reset_Q(T, Oldest, NewView++[{Node,Age}])
 		end;
reset_Q([], _, NewView) ->
 	NewView.

del_in_view(View, ToDel) ->
	 lists:filter(fun ({Node,_}) -> Node/=ToDel end, View).

handle_period(View, SubsetSize, ExpectedNodes, Id, ReqNodes, Oldest, Turn) ->
	case length(View)==0 of
		true -> 
			timer:send_after(3000, period),
			timer:send_after(1000, {timeout, Oldest}),
			exec(View, SubsetSize, ExpectedNodes, Id, Turn);
		false ->
			%io:format("~p sends to oldest ~p : ~p \n", [Id, Oldest, ReqNodes]),
			Oldest ! {request, ReqNodes, Id}, % TODO : don't send counts ideally
			timer:send_after(3000, period),
			timer:send_after(1000, {timeout, Oldest}),
			exec(reset_Q(View, Oldest, []), SubsetSize, [{Oldest,ReqNodes}] ++ ExpectedNodes, Id, Turn)
		end.

% [{'17',0},{'3',1}], ['3'], ['3'], 2
get_new_view(View, ReqNodes, RespWithoutId, SizeBound) ->
	%lists:uniq(fun({X, _}) -> X end, lists:filter(fun ({Node,_}) -> not lists:member(Node, ToDelete) end,View) ++ lists:map(fun (Node) -> {Node, 0} end, ToAdd)).
	ViewNodes = [Node || {Node, _} <-View],
	RespFiltered = lists:filter(fun (Node) -> not lists:member(Node, ViewNodes) end, RespWithoutId),
	ToAdd = lists:map(fun (Node) -> {Node, 0} end, RespFiltered),
	NewView = View ++ ToAdd,
	Deletable = lists:filter(fun (Node) -> not lists:member(Node, RespWithoutId) end, ReqNodes),
	prune(NewView, Deletable, SizeBound).

%node:prune([{'5',1},{'28',1},{'33',1}, {'3',1},{'37',1},{'99',1},{'40',0},{'67',0},{'11',0},{'62',0},{'81',0},{'17',0}],['37','28'],10).
prune(NewView, Deletable, SizeBound) ->
	case length(NewView)>SizeBound of 
		true ->
			ToPrune = lists:nth(1, Deletable),
			PrunedView = lists:filter(fun ({Node, _}) -> Node/=ToPrune end,NewView),
			prune(PrunedView, lists:filter(fun (Node) -> Node/=ToPrune end, Deletable), SizeBound); 
		false -> 
			NewView
		end.

get_request_subset(ToAck, ExpectedNodes) -> 
	case lists:dropwhile(fun({Node,_}) -> Node/=ToAck end, ExpectedNodes) of 
		[] -> 
			nosubset;
		[{_,ToR}|_] ->
			ToR
		end.

logging(Id, View, Turn) -> 
	FilePath = "log.csv",
	lists:foreach(fun({Node, Age}) -> 
			file:write_file(FilePath, lists:concat([Id, ",", Turn, ",", Node, ",", Age,"\n"]), [append])
			end, View).

init_view(N, Id) -> 
	make_view(N div 10, [], N,  list_to_atom(integer_to_list(Id)),  list_to_atom(integer_to_list(rand:uniform(N)))).

make_view(0, CurList, _, _, _) -> CurList;
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

start_nodes(0, Cluster, _) -> Cluster;
start_nodes(Cur, Cluster, N) ->
    Node = list_to_atom(integer_to_list(Cur)),
	View = init_view(N, Cur),
	NodePid = spawn(?MODULE, exec, [View, N div 20, [], Node, 0]),
	register(Node, NodePid),
	period(NodePid),
    start_nodes(Cur - 1, [Node | Cluster], N).

% create_files(0) ->
% 	io:format("Files were created\n");
% create_files(Id) ->
% 	FilePath = string:concat(integer_to_list(Id),"log.csv"), 
% 	Columns = "Id, Turn, Node, Age",
% 	file:write_file(FilePath, Columns),
% 	create_files(Id-1).
create_file() ->
	FilePath = "log.csv", 
	Columns = "Id,Turn,Node,Age\n",
	file:write_file(FilePath, Columns).

main() ->
	start_nodes(100, [], 100),
	create_file(),
	ok.
