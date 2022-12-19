## MAIN VARIABLES
ERLC = erl -compile
ESCRIPT = escript

## ARGS VARIABLES
N_NODE = 100#			1000	
VIEW_FRAC = 0.1#		0.2
SUBSET_FRAC = 0.05#		0.1
LOG_FILE = log.csv
WAIT_TIME = 440000#		+/- 50 rounds

## PATHS
# BUILD
FILE_RUNNER = runner.erl
FILE_NODE = node.erl
FILE_VIEW = view.erl
FILE_LOG = log.erl

## BUILDER
# This command take a Erlang source file and compile it to return a .beam file
build:
	$(ERLC) $(FILE_NODE) $(FILE_VIEW) $(FILE_LOG)

## RUNNERS
run:
	$(ESCRIPT) $(FILE_RUNNER) $(N_NODE) $(VIEW_FRAC) $(SUBSET_FRAC) $(LOG_FILE) $(WAIT_TIME)

## LOGS GENERATOR
### RPS
log_view10_nodes100:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.10 0.05 log_view10_nodes100.csv 1240000
log_view10_nodes500:
	$(ESCRIPT) $(FILE_RUNNER) 500 0.10 0.05 log_view10_nodes500.csv 1240000
log_view20_nodes100:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.20 0.05 log_view20_nodes100.csv 1240000
log_view20_nodes500:
	$(ESCRIPT) $(FILE_RUNNER) 500 0.20 0.05 log_view20_nodes500.csv 1240000

log_part01:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.10 0.05 log_view10_nodes100_xp1.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 100 0.10 0.05 log_view10_nodes100_xp2.csv 1240000
log_part02:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.10 0.05 log_view10_nodes100_xp3.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 100 0.10 0.05 log_view10_nodes100_xp4.csv 1240000
log_part03:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.10 0.05 log_view10_nodes100_xp5.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 500 0.10 0.05 log_view10_nodes500_xp1.csv 1240000
log_part04:
	$(ESCRIPT) $(FILE_RUNNER) 500 0.10 0.05 log_view10_nodes500_xp2.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 500 0.10 0.05 log_view10_nodes500_xp3.csv 1240000
log_part05:
	$(ESCRIPT) $(FILE_RUNNER) 500 0.10 0.05 log_view10_nodes500_xp4.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 500 0.10 0.05 log_view10_nodes500_xp5.csv 1240000
log_part06:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.20 0.05 log_view20_nodes100_xp1.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 100 0.20 0.05 log_view20_nodes100_xp2.csv 1240000
log_part07:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.20 0.05 log_view20_nodes100_xp3.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 100 0.20 0.05 log_view20_nodes100_xp4.csv 1240000
log_part08:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.20 0.05 log_view20_nodes100_xp5.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 500 0.20 0.05 log_view20_nodes500_xp1.csv 1240000
log_part09:
	$(ESCRIPT) $(FILE_RUNNER) 500 0.20 0.05 log_view20_nodes500_xp2.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 500 0.20 0.05 log_view20_nodes500_xp3.csv 1240000
log_part10:
	$(ESCRIPT) $(FILE_RUNNER) 500 0.20 0.05 log_view20_nodes500_xp4.csv 1240000
	$(ESCRIPT) $(FILE_RUNNER) 500 0.20 0.05 log_view20_nodes500_xp5.csv 1240000

## CLEAN
# This command clean the project by deleting output file
clean:
	@rm -f `find . -type f -name '*.beam'`
	@rm -f `find . -type f -name '*.dump'`
	@printf "All '*.beam' & '*.dump' files cleaned in the 'src' directory\n"

.PHONY: clean build run