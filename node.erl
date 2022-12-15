-module(node).
-compile(export_all).

exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop) -> % Should subset size be adapted, were part of nodes to die ?
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
	% 		io:format("Exec of ~p, View : ~p, ViewSize ~p\n", [Id, View, ViewSize])
	% 	end,
	handle_stop(Stop),
	receive
		{request, _, ReqNode} ->  			
			case length(View)==0 of
				true ->
					RespNodes = [],
					ReqNode ! {response, RespNodes, Id};
				false -> % [{'17',0},{'3',1}], ['3'], ['3'], 2 | [{'17',0},{'3',1}], ['3','42'], ['5'], 2
					{First,_} = lists:nth(rand:uniform(length(View)), View),
					RespNodes = node:sample([], View, SubsetSize-1, First, ReqNode),
					%%io:format("~p, request from ~p with subset ~p, respond with ~p\n", [Id, ReqNode, ReqNodes, RespNodes]),
					ReqNode ! {response, RespNodes, Id}
				end, %ReqNodes, RespWithoutId
			%NewView = get_new_view(View, RespNodes, ReqNodes, ViewSize),
			% case Id=='1' of 
			% 	false ->
			% 		Z=1;
			% 	true ->
			% 		io:format("receive request from ~p : ~p ; respond with ~p ; View becomes ~p\n", [ReqNode, ReqNodes, RespNodes, NewView])
			% 	end, 
			%logging(Id, NewView, Turn),			
			exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop);
		{response, RespNodes, RespNode} ->
			RespWithoutId = lists:filter(fun (Node) -> Node/=Id end, RespNodes ),
			ReqNodes = node:get_request_subset(RespNode, ExpectedNodes),	
			NewView = node:get_new_view(View, ReqNodes, RespWithoutId, ViewSize),
			NewExpected = lists:filter(fun ({Node,_}) -> Node/=RespNode end, ExpectedNodes),
			%logging(Id, NewView, Turn),
			% case Id=='1' of 
			% 	false ->
			% 		Z=1;
			% 	true ->
			% 		io:format("receive response from ~p : ~p ; View becomes ~p\n", [RespNode, RespNodes, NewView])
			% 	end, 
			exec(NewView, SubsetSize, ViewSize, NewExpected, Id, Turn, Stop);
		period ->
			NewView = inc(View),
			{Oldest, _} = oldest(-1, -1, NewView),
			ReqNodes = node:sample([], NewView, SubsetSize-1, Oldest, Oldest),
			logging(Id, NewView, Turn),
			% case Id=='1' of 
			% 	false ->
			% 		W=1;
			% 	true ->
			% 		io:format("send request to ~p : ~p \n", [Oldest, ReqNodes])
			% 	end, 
			%handle_period(NewView,SubsetSize,ViewSize, ExpectedNodes,Id,ReqNodes, Oldest, Turn+1);	
			case length(NewView)==0 of
				true -> 
					timer:send_after(8000, period),
					timer:send_after(6000, {timeout, Oldest}),
					exec(NewView, SubsetSize, ViewSize ,ExpectedNodes, Id, Turn, Stop);
				false ->
					%io:format("~p sends to oldest ~p : ~p \n", [Id, Oldest, ReqNodes]),
					Oldest ! {request, ReqNodes, Id}, % TODO : don't send counts ideally
					timer:send_after(8000, period),
					timer:send_after(6000, {timeout, Oldest}),
					NewExpected =  [{Oldest,ReqNodes}] ++ ExpectedNodes,
					exec(reset_Q(NewView, Oldest, []), SubsetSize, ViewSize, NewExpected, Id, Turn+1, Stop)
				end;				
		{timeout, ToCheck} ->
			case  lists:member(ToCheck, [Node || {Node, _} <- ExpectedNodes]) of 
				true -> % node did not respond in time, remove it of the view	lists:filter(fun ({Node,_}) -> Node/=ToDel end, View).				
					io:format("HEREEEEEEEEE ~p ~p \n", [Id, ToCheck]),
					logging(Id, [{ToCheck,-2}], Turn),
					NewView = del_in_view(View, ToCheck),
					NewExpected =  lists:filter(fun({Node,_}) -> Node/=ToCheck end, ExpectedNodes),
					exec(NewView, SubsetSize,ViewSize, NewExpected, Id, Turn, Stop);
				false ->%[[],[{'25',0},{'12',0},{'40',0},{'7',0},{'39',0}],2,{'39',0}]
					exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop)
			end;
		stop -> 
			logging(Id, [{Id,-1}], Turn),
			exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, true)
	end.


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
			{Next, _} = lists:nth(rand:uniform(length(View)), View),
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

% handle_period(View, SubsetSize, ViewSizeExpectedNodes, Id, ReqNodes, Oldest, Turn) ->
% 	case length(View)==0 of
% 		true -> 
% 			timer:send_after(10000, period),
% 			timer:send_after(7000, {timeout, Oldest}),
% 			exec(View, SubsetSize, ExpectedNodes, Id, Turn);
% 		false ->
% 			%io:format("~p sends to oldest ~p : ~p \n", [Id, Oldest, ReqNodes]),
% 			Oldest ! {request, ReqNodes, Id}, % TODO : don't send counts ideally
% 			timer:send_after(10000, period),
% 			timer:send_after(7000, {timeout, Oldest}),
% 			exec(reset_Q(View, Oldest, []), SubsetSize, [{Oldest,ReqNodes}] ++ ExpectedNodes, Id, Turn)
% 		end.

% [{'17',0},{'3',1}], ['3'], ['3'], 2 | [{'17',0},{'3',1}], ['3','42'], ['5'], 2
get_new_view(View, ReqNodes, RespWithoutId, SizeBound) ->
	%lists:uniq(fun({X, _}) -> X end, lists:filter(fun ({Node,_}) -> not lists:member(Node, ToDelete) end,View) ++ lists:map(fun (Node) -> {Node, 0} end, ToAdd)).
	ViewNodes = [Node || {Node, _} <-View],
	RespFiltered = lists:filter(fun (Node) -> not lists:member(Node, ViewNodes) end, RespWithoutId),
	ToAdd = lists:map(fun (Node) -> {Node, 0} end, RespFiltered),
	{NewView, RemainingToAdd} = fill_view(View, ToAdd, SizeBound), % to replace
	Deletables1 = lists:filter(fun (Node) -> not lists:member(Node, RespWithoutId) end, ReqNodes),
	Deletables2 = lists:filter(fun (Node) -> lists:member(Node, ViewNodes) end, Deletables1),
	prune(NewView, Deletables2, RemainingToAdd).


fill_view(View, ToAdd, SizeBound) ->
	case length(View)==SizeBound of
		true ->
			{View, ToAdd};
		false ->
			Index = rand:uniform(length(ToAdd)),
			PairToAdd = lists:nth(Index, ToAdd),
			NewView = View ++ [PairToAdd],
			NewToAdd = lists:delete(PairToAdd, ToAdd),
			fill_view(NewView, NewToAdd, SizeBound)
		end.
%node:prune([{'5',1},{'28',1},{'33',1}, {'3',1},{'37',1},{'99',1},{'40',0},{'67',0},{'11',0},{'62',0},{'81',0},{'17',0}],['37','28'],10).
prune(NewView, _, []) ->
	NewView;
prune(NewView, [], _) ->
	NewView;
prune(NewView, Deletables, ToAdd) ->
	IndexDel = rand:uniform(length(Deletables)),
	NodeToDel = lists:nth(IndexDel, Deletables),
	
	IndexAdd = rand:uniform(length(ToAdd)),
	PairToAdd = lists:nth(IndexAdd, ToAdd),

	ViewDel = lists:filter(fun({Node,_})-> Node/=NodeToDel end, NewView),
	ViewAdd = ViewDel ++ [PairToAdd],

	prune(ViewAdd, lists:delete(NodeToDel,Deletables), lists:delete(PairToAdd, ToAdd)).

get_request_subset(ToAck, ExpectedNodes) -> 
	case lists:dropwhile(fun({Node,_}) -> Node/=ToAck end, ExpectedNodes) of 
		[] -> 
			[];
		[{_,ToR}|_] ->
			ToR
		end.

logging(Id, View, Turn) -> 
	FilePath = "log.csv",
	lists:foreach(fun({Node, Age}) -> 
			file:write_file(FilePath, lists:concat([Id, ",", Turn, ",", Node, ",", Age,"\n"]), [append])
			end, View).

init_view(N, Id, ViewSize) -> 
	make_view(ViewSize, [], N,  list_to_atom(integer_to_list(Id)),  list_to_atom(integer_to_list(rand:uniform(N)))).

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

start_nodes(0, Cluster, _, _, _) -> Cluster;
start_nodes(Cur, Cluster, N, ViewSize, SubsetSize) ->
	io:format("~p\n", [N]),
    Node = list_to_atom(integer_to_list(Cur)),
	View = init_view(N, Cur, ViewSize),
	NodePid = spawn(?MODULE, exec, [View, SubsetSize, ViewSize, [], Node, 0, false]),
	register(Node, NodePid),
	period(NodePid, Cur, N),
    start_nodes(Cur - 1, [Node | Cluster], N, ViewSize, SubsetSize).



period(Pid, Cur, N) ->
	timer:send_after(8000+round((N-Cur)/2), Pid, period). 

create_file() ->
	FilePath = "log.csv", 
	Columns = "Id,Turn,Node,Age\n",
	file:write_file(FilePath, Columns).

kill_after(N, Time) ->	
	PidToKill = list_to_atom(integer_to_list(N)),
	timer:send_after(Time, PidToKill, stop).

handle_stop(Stop) ->
	case Stop of 
		true ->
			receive 
				never_received -> 
					handle_stop(Stop)
			end;
		_ -> ok
	end.

main() ->
	N_NODE = 1000,
	VIEW_FRAC = 0.2,
	SUBSET_FRAC = 0.1,
	ViewSize = round(N_NODE*VIEW_FRAC),
	SubsetSize = round(N_NODE*SUBSET_FRAC),
	start_nodes(N_NODE, [], N_NODE, ViewSize, SubsetSize),
	create_file(),
	kill_after(rand:uniform(N_NODE), 50*8000),
	ok.
