-module(log).
-compile(export_all).

create_file() ->
	FilePath = "log.csv", 
	Columns = "Id,Turn,Node,Age\n",
	file:write_file(FilePath, Columns).

logging(Id, View, Turn) -> 
	FilePath = "log.csv",
	lists:foreach(
		fun({Node, Age}) -> 
			file:write_file(FilePath, lists:concat([Id, ",", Turn, ",", Node, ",", Age,"\n"]), [append])
		end,
	View).