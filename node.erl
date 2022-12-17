-module(node).
-compile(export_all).

init(Cur, N, ViewSize, SubsetSize) ->
    Node = list_to_atom(integer_to_list(Cur)),
	View = view:init(N, Cur, ViewSize),
	io:format("View => ~p\n", [View]),
	NodePid = spawn(?MODULE, exec, [View, SubsetSize, ViewSize, [], Node, 0, false]),
	register(Node, NodePid),
	period(NodePid, Cur, N),
	Node.

exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop) -> % Should subset size be adapted, were part of nodes to die ?
	%%io:format("node ~p view : ~p\n", [Id,View]),
	handle_stop(Stop),
	receive
		{request, _, ReqNode} ->  			
			case length(View)==0 of
				true ->
					RespNodes = [],
					ReqNode ! {response, RespNodes, Id};
				false -> % [{'17',0},{'3',1}], ['3'], ['3'], 2 | [{'17',0},{'3',1}], ['3','42'], ['5'], 2
					{First,_} = lists:nth(rand:uniform(length(View)), View),
					RespNodes = sample([], View, SubsetSize-1, First, ReqNode),
					%%io:format("~p, request from ~p with subset ~p, respond with ~p\n", [Id, ReqNode, ReqNodes, RespNodes]),
					ReqNode ! {response, RespNodes, Id}
			end, %ReqNodes, RespWithoutId
			%NewView = view:get_new(View, RespNodes, ReqNodes, ViewSize),
			% case Id=='1' of 
			% 	false ->
			% 		Z=1;
			% 	true ->
			% 		io:format("receive request from ~p : ~p ; respond with ~p ; View becomes ~p\n", [ReqNode, ReqNodes, RespNodes, NewView])
			% 	end, 
			%log:logging(Id, NewView, Turn),			
			exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop);
		{response, RespNodes, RespNode} ->
			RespWithoutId = lists:filter(fun (Node) -> Node/=Id end, RespNodes ),
			ReqNodes = node:get_request_subset(RespNode, ExpectedNodes),	
			NewView = view:get_new(View, ReqNodes, RespWithoutId, ViewSize),
			NewExpected = lists:filter(fun ({Node,_}) -> Node/=RespNode end, ExpectedNodes),
			%log:logging(Id, NewView, Turn),
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
			ReqNodes = sample([], NewView, SubsetSize-1, Oldest, Oldest),
			log:logging(Id, NewView, Turn),
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
					exec(view:reset_age(NewView, Oldest, []), SubsetSize, ViewSize, NewExpected, Id, Turn+1, Stop)
			end;				
		{timeout, ToCheck} ->
			case  lists:member(ToCheck, [Node || {Node, _} <- ExpectedNodes]) of 
				true -> % node did not respond in time, remove it of the view	lists:filter(fun ({Node,_}) -> Node/=ToDel end, View).				
					io:format("HEREEEEEEEEE ~p ~p \n", [Id, ToCheck]),
					log:logging(Id, [{ToCheck,-2}], Turn),
					NewView = view:del_node(View, ToCheck),
					NewExpected =  lists:filter(fun({Node,_}) -> Node/=ToCheck end, ExpectedNodes),
					exec(NewView, SubsetSize,ViewSize, NewExpected, Id, Turn, Stop);
				false ->%[[],[{'25',0},{'12',0},{'40',0},{'7',0},{'39',0}],2,{'39',0}]
					exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop)
			end;
		stop -> 
			log:logging(Id, [{Id,-1}], Turn),
			exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, true)
	end.

inc([]) 		-> [];
inc([{N, C}|T]) -> [{N, C+1}|inc(T)].

% to test : node:oldest(-1, -1, [{'77',1},{'26',1},{'51',1},{'36',1},{'66',1},{'48',3},{'54',1},{'6',3},{'33',1},{'81',1}]).
oldest(CurOldest, Age, []) 							-> {CurOldest, Age};
oldest(CurOldest, OldestAge, [{Candidate, Age}|T]) 	->
	case OldestAge>Age of 
		true 	-> oldest(CurOldest, OldestAge, T);
		false 	-> oldest(Candidate, Age, T)
	end.

% to test : node:sample([], [{'7',4},{'71',4}, {'25',4}], 2, {'71',4}).
sample(CurList, _, 0, _, _) 				-> CurList;
sample(CurList, View, R, Candidate, Oldest) ->
	case length(CurList)==length(View) of 
		true 	-> CurList; % in case view too small 
		false 	->
			{Next, _} = lists:nth(rand:uniform(length(View)), View),
			case lists:member(Candidate, CurList) orelse Candidate==Oldest of 
				true 	-> sample(CurList, View, R, Next, Oldest);
				false 	-> sample([Candidate|CurList], View, R-1, Next, Oldest)
			end
	end.

get_request_subset(ToAck, ExpectedNodes) -> 
	case lists:dropwhile(fun({Node,_}) -> Node/=ToAck end, ExpectedNodes) of 
		[] 			-> [];
		[{_,ToR}|_] -> ToR
	end.

period(Pid, Cur, N) -> timer:send_after(8000+round((N-Cur)/2), Pid, period). 

handle_stop(Stop) ->
	case Stop of 
		true 	-> receive never_received -> handle_stop(Stop) end;
		_ 		-> ok
	end.