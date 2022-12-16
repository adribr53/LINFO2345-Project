-module(view).
-compile(export_all).

init(N, Id, ViewSize) -> create(ViewSize, [], N,  list_to_atom(integer_to_list(Id)),  list_to_atom(integer_to_list(rand:uniform(N)))).

create(0, CurList, _, _, _) 			-> CurList;
create(R, CurList, N, Id, Candidate) 	->	
	case Id==Candidate of 
		true 	-> create(R, CurList, N, Id, list_to_atom(integer_to_list(rand:uniform(N))) );
		false 	->
			case lists:member({Candidate,0}, CurList) of
				true 	-> create(R, CurList, N, Id, list_to_atom(integer_to_list(rand:uniform(N))) );			
				false 	-> create(R-1, [{Candidate,0} | CurList], N, Id, list_to_atom(integer_to_list(rand:uniform(N))))
			end
	end.

% to test : node:reset_subset([{'7',4},{'71',4}, {'25',4}, {'78',4},{'22',4},{'42',4},{'73',4},{'58',4},{'15',5},{'3',4}], {'15',5}, []). 
reset_age([], _, NewView) 					-> NewView;
reset_age([{Node,Age}|T], Oldest, NewView) 	-> 
 	case Node==Oldest of
 		true 	-> (NewView ++ [{Node,0}]) ++ T;
 		false 	-> reset_age(T, Oldest, NewView++[{Node,Age}])
	end.

del_node(View, ToDel) -> lists:filter(fun ({Node,_}) -> Node/=ToDel end, View).

% [{'17',0},{'3',1}], ['3'], ['3'], 2 | [{'17',0},{'3',1}], ['3','42'], ['5'], 2
get_new(View, ReqNodes, RespWithoutId, SizeBound) ->
	%lists:uniq(fun({X, _}) -> X end, lists:filter(fun ({Node,_}) -> not lists:member(Node, ToDelete) end,View) ++ lists:map(fun (Node) -> {Node, 0} end, ToAdd)).
	ViewNodes = [Node || {Node, _} <-View],
	RespFiltered = lists:filter(fun (Node) -> not lists:member(Node, ViewNodes) end, RespWithoutId),
	ToAdd = lists:map(fun (Node) -> {Node, 0} end, RespFiltered),
	{NewView, RemainingToAdd} = fill(View, ToAdd, SizeBound), % to replace
	Deletables1 = lists:filter(fun (Node) -> not lists:member(Node, RespWithoutId) end, ReqNodes),
	Deletables2 = lists:filter(fun (Node) -> lists:member(Node, ViewNodes) end, Deletables1),
	prune(NewView, Deletables2, RemainingToAdd).

fill(View, ToAdd, SizeBound) ->
	case length(View)==SizeBound of
		true 	-> {View, ToAdd};
		false 	->
			Index = rand:uniform(length(ToAdd)),
			PairToAdd = lists:nth(Index, ToAdd),
			NewView = View ++ [PairToAdd],
			NewToAdd = lists:delete(PairToAdd, ToAdd),
			fill(NewView, NewToAdd, SizeBound)
	end.

%node:prune([{'5',1},{'28',1},{'33',1}, {'3',1},{'37',1},{'99',1},{'40',0},{'67',0},{'11',0},{'62',0},{'81',0},{'17',0}],['37','28'],10).
prune(NewView, _, []) 				-> NewView;
prune(NewView, [], _) 				-> NewView;
prune(NewView, Deletables, ToAdd) 	->
	IndexDel = rand:uniform(length(Deletables)),
	NodeToDel = lists:nth(IndexDel, Deletables),
	
	IndexAdd = rand:uniform(length(ToAdd)),
	PairToAdd = lists:nth(IndexAdd, ToAdd),

	ViewDel = lists:filter(fun({Node,_})-> Node/=NodeToDel end, NewView),
	ViewAdd = ViewDel ++ [PairToAdd],

	prune(ViewAdd, lists:delete(NodeToDel,Deletables), lists:delete(PairToAdd, ToAdd)).
