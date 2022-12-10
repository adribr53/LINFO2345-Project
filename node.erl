-module(node).
-compile(export_all).

exec(View, SubsetSize, ExpectedNodes, Id) -> % Should subset size be adapted, were part of nodes to die ?
	%io:format("Hi, I'm node ~p with view ~p\n", [Id, View]),
	case length(View)/=2*SubsetSize of
		true ->
			io:format("node ~p view : ~p\n", [Id,View]);
		false ->
			X=1
		end,
	receive
		{request, _, NodeId} ->   
			% respond to views sent
            %io:format("Hi, I'm node ~p receiving request from ~p\n", [Id, NodeId]),
			case length(View)==0 of
				true ->
					NodeId ! {response, [], Id};
				false ->
					NodeId ! {response, node:sample([], View, SubsetSize, lists:nth(rand:uniform(length(View)), View), {-1,0}), Id}
				end,			
			exec(View, SubsetSize, ExpectedNodes, Id);
		{response, Subset, NodeId} ->
			%exec(View, SubsetSize, ExpectedNodes, Id);
			% case Id=='1' of
			% 	true ->
			% 		io:format("Hi, I'm node ~p receiving response from ~p that is ~p\n", [Id, NodeId, Subset]);
			% 	false ->
			% 		Y=1
			% 	end,
			handle_response(View, SubsetSize, ExpectedNodes, Id, [Node || {Node, _} <- lists:filter(fun ({Node,_}) -> Node/=Id end, Subset )], NodeId, node:get_request_subset(NodeId, ExpectedNodes));
		period ->
			%io:format("Hi, I'm node ~p having my period\n", [Id]), % CurList, View, R, Candidate, Oldest
			{Oldest, Age} = oldest(-1, -1, inc(View)),
			Subset = node:sample([], inc(View), SubsetSize, {Oldest, Age}, {Oldest, Age}),
			case Id=='1' of
				true ->
					io:format("Coucou : ~p, ~p, ~p\n", [inc(View), SubsetSize, Oldest]);
				% Oldest is without the age !!!!!!
				false ->
					F=1
				end,
			handle_period(inc(View),SubsetSize,ExpectedNodes,Id,Subset, Oldest);						
		{timeout, ToCheck} ->
			%io:format("Hi, I'm node ~p checking timeout for ~p\n", [Id, ToCheck]),
			case  lists:member(ToCheck, [Node || {Node, _} <- ExpectedNodes]) of 
				true -> % node did not respond in time, remove it of the view	lists:filter(fun ({Node,_}) -> Node/=ToDel end, View).				
					exec(del_in_view(View, ToCheck), SubsetSize, lists:filter(fun({Node,_}) -> Node/=ToCheck end, ExpectedNodes) , Id);
				false ->%[[],[{'25',0},{'12',0},{'40',0},{'7',0},{'39',0}],2,{'39',0}]
					exec(View, SubsetSize, ExpectedNodes, Id)
			end
	end.

period(Pid) ->
	timer:send_after(300, Pid, period). 

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

% to test : node:sample([], [{'7',4},{'71',4}, {'25',4}], 2, {'71',4}).
sample(CurList, _, 0, _, _) -> 
	CurList;
sample(CurList, View, R, Candidate, Oldest) ->
	%%io:format("View : ~p ; CurList ~p\n", [View, CurList]),
	%%io:format("Lengths : ~p ; CurList ~p\n", [length(View), length(CurList)]),
	%%io:format("Lengths : ~p\n", [length(View)==length(CurList)]),
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
	% case Id=='1' of
	% 	true ->
	% 		io:format("Hi, I'm node ~p sendiong request to ~p that is ~p\n", [Id, Oldest, Subset]);
	% 	false ->
	% 		Z=1
	% 	end,
	case length(View)==0 of
		true -> 
			node:exec(View, SubsetSize, ExpectedNodes, Id);
		false ->
			%io:format("~p\n", [Oldest]),
			Oldest ! {request, Subset, Id}, % TODO : don't send counts ideally
			timer:send_after(3000, period),
			timer:send_after(1000, {timeout, Oldest}),
			node:exec(node:reset_Q(View, Oldest, []), SubsetSize, [{Oldest,Subset}] ++ ExpectedNodes, Id)
		end.

%Oldest : '3' reset_Q : [{'12',17},{'3',17},{'14',16},{'7',16},{'10',16}]
% then: [{'12',17},{'3',17},{'14',16},{'7',16},{'10',16}]
%lists:uniq(fun({X, _}) -> X end, lists:merge(Subset,View))
handle_response(View, SubsetSize, ExpectedNodes, Id, RespSubset, ToAck, RequestSubset) ->
	% get_new_view(View, RespSubset, lists:filter(fun ({Node,_}) -> not lists:member(Node, RespSubset) end, RequestSubset))
	ToDel = node:get_to_del(RequestSubset, RespSubset, SubsetSize, length(View), View),
	ToAdd = node:get_to_add([X || {X,_} <- View], RespSubset),
	% case Id=='1' of
	% 	true ->
	% 		io:format("ToDel : ~p, ToAdd : ~p, Resp Subset~p, View ~p\n", [ToDel,ToAdd, RespSubset, View]);
	% 	false ->
	% 		W=1
	% 	end,
	node:exec(node:get_new_view(View, ToAdd, ToDel), SubsetSize, lists:filter(fun ({Node,_}) -> Node/=ToAck end, ExpectedNodes), Id).

get_to_del(Req, Resp, SubsetSize, ViewSize, View) -> %nb to del : max(0,length(ToAdd)-(SubsetSize-length(View)))
	lists:sublist([ToR || {ToR, _} <-  lists:filter(fun ({Node,_}) -> not lists:member(Node, Resp) end, Req)], lists:max([0,length(get_to_add([X || {X,_} <- View], Resp))-(SubsetSize*2-ViewSize)])).

get_to_add(ViewNode, Resp) -> %[Node || {Node, _} <- ExpectedNodes]
	lists:filter(fun (Node) -> not lists:member(Node, ViewNode) end, Resp).
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
	View = init_view(N, Cur),
	NodePid = spawn(?MODULE, exec, [View, N div 20, [], Node]),
	register(Node, NodePid),
	period(NodePid),
	io:format("Hi, I'm node ~p with view ~p\n", [Node, View]),
    start_nodes(Cur - 1, [Node | Cluster], N).

main() ->
	start_nodes(120, [], 120),
    %timer:send_interval(300, list_to_atom(integer_to_list(rand:uniform(5))), view),
	ok.
