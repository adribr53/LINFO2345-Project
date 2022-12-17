-module(byzantine).
-export([init/5, exec/8]).

exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop, Logger) ->
	node:handle_stop(Stop),
	receive
		{request, _, ReqNode} ->
			case length(View)==0 of
				true 	->
					RespNodes = [],
					ReqNode ! {response, RespNodes, Id};
				false 	->
					{First,_} = lists:nth(rand:uniform(length(View)), View),
					RespNodes = node:sample([], View, SubsetSize-1, First, ReqNode),
					%io:format("Byzantine node ~p sends evil subset to ~p:\n~p\n", [Id, ReqNode, RespNodes]),
					ReqNode ! {response, RespNodes, Id}
			end,			
			exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, Stop, Logger);
		stop -> 
			Logger ! {register, Id, [{Id,-1}], Turn},
			exec(View, SubsetSize, ViewSize, ExpectedNodes, Id, Turn, true, Logger)
	end.

init(Cur, NodeList, ViewSize, SubsetSize, Logger) ->
    Node = list_to_atom(integer_to_list(Cur)),
	View = view:init_from_list(Cur, NodeList),
	%io:format("ByzantineView => ~p\n", [View]),
	NodePid = spawn(?MODULE, exec, [View, SubsetSize, ViewSize, [], Node, 0, false, Logger]),
	register(Node, NodePid),
	Node.
