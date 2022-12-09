-module(node).
-compile(export_all).

exec(View, SubsetSize, ExpectedNodes, Id) -> % Should subset size be adapted, were part of nodes to die ?
	io:format("Hi, I'm node ~p with view ~p\n", [Id, View]),
	receive
		{request, _, NodeId} ->   
			% respond to views sent
            io:format("Hi, I'm node ~p receiving request from ~p\n", [Id, NodeId]),
			NodeId ! {response, node:sample([], View, SubsetSize, lists:nth(rand:uniform(length(View)), View), {-1,0}), Id},			
			exec(View, SubsetSize, ExpectedNodes, Id);
		{response, Subset, NodeId} ->
			%exec(View, SubsetSize, ExpectedNodes, Id);
			io:format("Hi, I'm node ~p receiving response from ~p\n", [Id, NodeId]),
			handle_response(View, SubsetSize, ExpectedNodes, Id, [Node || {Node, _} <- lists:filter(fun ({Node,_}) -> Node/=Id end, Subset )], NodeId, node:get_request_subset(NodeId, ExpectedNodes));
		period ->
			io:format("Hi, I'm node ~p having my period\n", [Id]), % CurList, View, R, Candidate, Oldest
			io:format("arguments :  ~p\n", [oldest(-1, -1, View)]),
			handle_period(inc(View),SubsetSize,ExpectedNodes,Id,node:sample([], inc(View), SubsetSize, oldest(-1, -1, inc(View)), oldest(-1, -1, inc(View))), oldest(-1, -1, inc(View)));						
		{timeout, ToCheck} ->
			io:format("Hi, I'm node ~p checking timeout for ~p\n", [Id, ToCheck]),
			case  lists:member(ToCheck, [Node || {Node, _} <- ExpectedNodes]) of 
				true -> % node did not respond in time, remove it of the view	lists:filter(fun ({Node,_}) -> Node/=ToDel end, View).				
					exec(del_in_view(View, ToCheck), SubsetSize, lists:filter(fun({Node,_}) -> Node/=ToCheck end, ExpectedNodes) , Id);
				false ->%[[],[{'25',0},{'12',0},{'40',0},{'7',0},{'39',0}],2,{'39',0}]
					exec(View, SubsetSize, ExpectedNodes, Id)
			end
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
oldest(CurOldest, _, []) ->
	CurOldest.

% to test : node:sample([], [{'7',4},{'71',4}, {'25',4}], 2, {'71',4}).
sample(CurList, _, 0, _, _) -> 
	CurList;
sample(CurList, View, R, Candidate, Oldest) ->
	%io:format("View : ~p ; CurList ~p\n", [View, CurList]),
	%io:format("Lengths : ~p ; CurList ~p\n", [length(View), length(CurList)]),
	%io:format("Lengths : ~p\n", [length(View)==length(CurList)]),
	case length(CurList)==length(View) of 
		true -> % in case view too small 
			CurList;
		false ->
			case lists:member(Candidate, CurList) orelse Candidate==Oldest of 
				true ->
					node:sample(CurList, View, R, lists:nth(rand:uniform(length(View)), View), Oldest);
				false ->
					node:sample([Candidate|CurList], View, R-1, lists:nth(rand:uniform(length(View)), View), Oldest)
				end
		end.

% to test : node:reset_subset([{'7',4},{'71',4}, {'25',4}, {'78',4},{'22',4},{'42',4},{'73',4},{'58',4},{'15',5},{'3',4}], {'15',5}, []).
reset_Q([{Node,Age}|T], Oldest, NewView) -> 
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

handle_period(View, SubsetSize, ExpectedNodes, Id, Subset, Oldest) ->
	case length(View)==0 of
		true -> 
			node:exec(View, SubsetSize, ExpectedNodes, Id);
		false ->
			io:format("Hi, I'm node ~p about to send view to ~p in my period\n", [Id, Oldest]),
			Oldest ! {request, Subset, Id}, % TODO : don't send counts ideally
			timer:send_after(3000, period),
			timer:send_after(1000, {timeout, Oldest}),
			io:format("Oldest : ~p reset_Q : ~p\n then: ~p", [Oldest, View, node:reset_Q(View, Oldest, [])]),
			node:exec(node:reset_Q(View, Oldest, []), SubsetSize, [{Oldest,Subset}] ++ExpectedNodes, Id)
		end.

%Oldest : '3' reset_Q : [{'12',17},{'3',17},{'14',16},{'7',16},{'10',16}]
% then: [{'12',17},{'3',17},{'14',16},{'7',16},{'10',16}]
%lists:uniq(fun({X, _}) -> X end, lists:merge(Subset,View))
handle_response(View, SubsetSize, ExpectedNodes, Id, RespSubset, ToAck, RequestSubset) ->
	% get_new_view(View, RespSubset, lists:filter(fun ({Node,_}) -> not lists:member(Node, RespSubset) end, RequestSubset))
	node:exec(node:get_new_view(View, node:get_to_add(RequestSubset, RespSubset), node:get_to_del(RequestSubset, RespSubset)), SubsetSize, lists:filter(fun ({Node,_}) -> Node/=ToAck end, ExpectedNodes), Id ).

get_to_del(Req, Resp) ->
	[ToR || {ToR, _} <-  lists:filter(fun ({Node,_}) -> not lists:member(Node, Resp) end, Req)].

get_to_add(Req, Resp) -> %[Node || {Node, _} <- ExpectedNodes]
	io:format("hein\n"),
	io:format("~p, ~p\n", [Req, Resp]),
	lists:filter(fun (Node) -> not lists:member(Node, [ReqNode || {ReqNode, _} <- Req]) end, Resp).
%lists:uniq(fun({X, _}) -> X end, RespSubset++View)
get_new_view(View, ToAdd, ToDelete) ->
	% todo : check whether cache is full
	lists:uniq(fun({X, _}) -> X end, lists:filter(fun ({Node,_}) -> not lists:member(Node, ToDelete) end,View) ++ lists:map(fun (Node) -> {Node, 0} end, ToAdd)).

% node:get_new_view(View, RespSubset, get_to_del(RequestSubset, RespSubset)), SubsetSize, lists:filter(fun ({Node,_}) -> Node/=ToAck end, ExpectedNodes), Id ).
% [{'1',3},{'2',4},{'3',5}, {'4',6}]
% [{'1',3},{'2',4}]
% ['2','3']
get_request_subset(ToAck, ExpectedNodes) -> 
	case lists:dropwhile(fun({Node,_}) -> Node/=ToAck end, ExpectedNodes) of 
		[] -> 
			nosubset;
		[{_,ToR}|_] ->
			ToR
		end.

% https://stackoverflow.com/questions/10318156/how-to-create-a-list-of-1000-random-numbers-in-erlang
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
	NodePid = spawn(?MODULE, exec, [init_view(N, Cur), N div 20, [], Node]),
	register(Node, NodePid),
	period(NodePid),
    start_nodes(Cur - 1, [Node | Cluster], N).

main() ->
	start_nodes(20, [], 20),
    %timer:send_interval(300, list_to_atom(integer_to_list(rand:uniform(5))), view),
	ok.
