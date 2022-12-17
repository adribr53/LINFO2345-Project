-module(log).
-compile(export_all).

logging(File) ->
	receive
		{register, Id, View, Turn} ->
			lists:foreach(
				fun({Node, Age}) -> 
					file:write_file(File, lists:concat([Id, ",", Turn, ",", Node, ",", Age,"\n"]), [append])
				end,
			View),
			logging(File);
		close -> ok
	end.

create_file(File) ->
	Columns = "Id,Turn,Node,Age\n",
	file:write_file(File, Columns).

init(File) ->
	create_file(File),
	spawn(?MODULE, logging, [File]).
