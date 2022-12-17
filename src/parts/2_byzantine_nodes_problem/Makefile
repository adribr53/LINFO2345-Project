## MAIN VARIABLES
ERLC = erl -compile
ESCRIPT = escript

## ARGS VARIABLES
N_NODE = 100#			1000
BYZ_FRAC = 0.1#		
VIEW_FRAC = 0.1#		0.2
SUBSET_FRAC = 0.05#	0.1
LOG_FILE = log.csv
WAIT_TIME = 20000

## PATHS
# BUILD
FILE_RUNNER = runner.erl
FILE_NODE = node.erl
FILE_VIEW = view.erl
FILE_LOG = log.erl
FILE_BYZ_NODE = byzantine.erl

## BUILDER
# This command take a Erlang source file and compile it to return a .beam file
build:
	$(ERLC) $(FILE_NODE) $(FILE_VIEW) $(FILE_LOG) $(FILE_BYZ_NODE)

## RUNNERS
run:
	$(ESCRIPT) $(FILE_RUNNER) $(N_NODE) $(BYZ_FRAC) $(VIEW_FRAC) $(SUBSET_FRAC) $(LOG_FILE) $(WAIT_TIME)

## CLEAN
# This command clean the project by deleting output file
clean:
	@rm -f `find . -type f -name '*.beam'`
	@rm -f `find . -type f -name '*.dump'`
	@printf "All '*.beam' & '*.dump' files cleaned in the 'src' directory\n"

.PHONY: clean build run