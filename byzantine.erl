-module(byzantine).
-compile(export_all).

exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop) ->
	node:handle_stop(Stop),
	receive
		{request, _, ReqNode} ->
			case length(View)==0 of
				true ->
					RespNodes = [],
					ReqNode ! {response, RespNodes, Id};
				false ->
					{First,_} = lists:nth(rand:uniform(length(View)), View),
					RespNodes = node:sample([], View, SubsetSize-1, First, ReqNode),
					io:format("Byzantine node ~p sends evil subset to ~p:\n~p\n", [Id, ReqNode, RespNodes]),
					ReqNode ! {response, RespNodes, Id}
			end,			
			exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop);
		stop -> 
			log:logging(Id, [{Id,-1}], Turn),
			exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, true)
	end.

init(Cur, NodeList, ViewSize, SubsetSize) ->
    Node = list_to_atom(integer_to_list(Cur)),
	View = view:init_from_list(Cur, NodeList),
	io:format("ByzantineView => ~p\n", [View]),
	NodePid = spawn(?MODULE, exec, [View, SubsetSize, ViewSize, [], Node, 0, false]),
	register(Node, NodePid),
	Node.
