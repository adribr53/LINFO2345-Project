## MAIN VARIABLES
ERLC = erl -compile
ESCRIPT = escript

## ARGS VARIABLES
N_NODE = 100#			1000
BYZ_FRAC = 0.1#		
VIEW_FRAC = 0.1#		0.2
SUBSET_FRAC = 0.05#	0.1
LOG_FILE = log.csv
WAIT_TIME = 440000#		+/- 50 rounds

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

## LOGS GENERATOR
log_byz_perc_05:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.05 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_05_perc.csv $(WAIT_TIME)
log_byz_perc_06:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.06 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_06_perc.csv $(WAIT_TIME)
log_byz_perc_08:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.08 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_08_perc.csv $(WAIT_TIME)
log_byz_perc_10:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.10 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_10_perc.csv $(WAIT_TIME)
log_byz_perc_12:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.12 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_12_perc.csv $(WAIT_TIME)
log_byz_perc_14:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.14 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_14_perc.csv $(WAIT_TIME)
log_byz_perc_15:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.15 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_15_perc.csv $(WAIT_TIME)
log_byz_perc_16:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.16 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_16_perc.csv $(WAIT_TIME)
log_byz_perc_18:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.18 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_18_perc.csv $(WAIT_TIME)
log_byz_perc_20:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.20 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_20_perc.csv $(WAIT_TIME)
log_byz_perc_25:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.25 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_25_perc.csv $(WAIT_TIME)
log_byz_perc_30:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.30 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_30_perc.csv $(WAIT_TIME)
log_byz_perc_35:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.35 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_35_perc.csv $(WAIT_TIME)
log_byz_perc_40:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.40 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_40_perc.csv $(WAIT_TIME)
log_byz_perc_45:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.45 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_45_perc.csv $(WAIT_TIME)
log_byz_perc_50:
	$(ESCRIPT) $(FILE_RUNNER) 100 0.50 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_50_perc.csv $(WAIT_TIME)
log_byz_percs: log_byz_perc-10 log_byz_perc-20 log_byz_perc-30 log_byz_perc-40 log_byz_perc-50

## CLEAN
# This command clean the project by deleting output file
clean:
	@rm -f `find . -type f -name '*.beam'`
	@rm -f `find . -type f -name '*.dump'`
	@printf "All '*.beam' & '*.dump' files cleaned in the 'src' directory\n"

.PHONY: clean build run