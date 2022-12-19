## MAIN VARIABLES
ERLC = erl -compile
ESCRIPT = escript

## ARGS VARIABLES
N_NODE = 100#			1000
BYZ_FRAC = 0.1#		
VIEW_FRAC = 0.15#		0.2
SUBSET_FRAC = 0.075#	0.1
LOG_FILE = log.csv
WAIT_TIME = 520000

## PATHS
# BUILD
FILE_RUNNER = runner.erl
FILE_NODE = node.erl
FILE_VIEW = view.erl
FILE_LOG = log.erl
FILE_BYZ_NODE = byzantine.erl

MODULES_DIR = src/modules
PARTS_DIR = src/parts
PART1_DIR = 1_rps_implem
PART2_DIR = 2_byzantine_nodes_problem

# RUN
RUNNER_PART1 = $(PARTS_DIR)/$(PART1_DIR)/$(FILE_RUNNER)
RUNNER_PART2 = $(PARTS_DIR)/$(PART2_DIR)/$(FILE_RUNNER)

# ZIP
DIR_NAME = LINFO2345_GIOT_Adrien_JADIN_Guillaume
ZIP_NAME = ./$(DIR_NAME).zip
## FILES TO ARCHIVE
MODULES_FILES = $(FILE_NODE) $(FILE_VIEW) $(FILE_LOG)
PART1_FILES = $(FILE_RUNNER) Makefile README.md graphs
PART2_FILES = $(FILE_BYZ_NODE) $(PART1_FILES)
OTHER_FILES = report.pdf #README.md


## BUILDER
# This command take a Erlang source file and compile it to return a .beam file
build:
	$(ERLC) $(foreach file,${MODULES_FILES},${MODULES_DIR}/${file}) $(PARTS_DIR)/$(PART2_DIR)/$(FILE_BYZ_NODE)

## RUNNERS
run1:
	$(ESCRIPT) $(RUNNER_PART1) $(N_NODE) $(VIEW_FRAC) $(SUBSET_FRAC) $(LOG_FILE) 10000
	# OR
	# $(ESCRIPT) $(RUNNER_PART2) $(N_NODE) 0 $(VIEW_FRAC) $(SUBSET_FRAC) $(LOG_FILE) 10000
run2:
	$(ESCRIPT) $(RUNNER_PART2) $(N_NODE) $(BYZ_FRAC) $(VIEW_FRAC) $(SUBSET_FRAC) $(LOG_FILE) 10000

## LOGS GENERATOR
### RPS
log_view10_nodes100:
	$(ESCRIPT) $(RUNNER_PART1) 100 0.10 0.05 log_view10_nodes100.csv 1240000
log_view10_nodes500:
	$(ESCRIPT) $(RUNNER_PART1) 500 0.10 0.05 log_view10_nodes500.csv 1240000
log_view20_nodes100:
	$(ESCRIPT) $(RUNNER_PART1) 100 0.20 0.05 log_view20_nodes100.csv 1240000
log_view20_nodes500:
	$(ESCRIPT) $(RUNNER_PART1) 500 0.20 0.05 log_view20_nodes500.csv 1240000

log_part01:
	$(ESCRIPT) $(RUNNER_PART1) 100 0.10 0.05 log_view10_nodes100_xp1.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 100 0.10 0.05 log_view10_nodes100_xp2.csv 1240000
log_part02:
	$(ESCRIPT) $(RUNNER_PART1) 100 0.10 0.05 log_view10_nodes100_xp3.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 100 0.10 0.05 log_view10_nodes100_xp4.csv 1240000
log_part03:
	$(ESCRIPT) $(RUNNER_PART1) 100 0.10 0.05 log_view10_nodes100_xp5.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 500 0.10 0.05 log_view10_nodes500_xp1.csv 1240000
log_part04:
	$(ESCRIPT) $(RUNNER_PART1) 500 0.10 0.05 log_view10_nodes500_xp2.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 500 0.10 0.05 log_view10_nodes500_xp3.csv 1240000
log_part05:
	$(ESCRIPT) $(RUNNER_PART1) 500 0.10 0.05 log_view10_nodes500_xp4.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 500 0.10 0.05 log_view10_nodes500_xp5.csv 1240000
log_part06:
	$(ESCRIPT) $(RUNNER_PART1) 100 0.20 0.05 log_view20_nodes100_xp1.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 100 0.20 0.05 log_view20_nodes100_xp2.csv 1240000
log_part07:
	$(ESCRIPT) $(RUNNER_PART1) 100 0.20 0.05 log_view20_nodes100_xp3.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 100 0.20 0.05 log_view20_nodes100_xp4.csv 1240000
log_part08:
	$(ESCRIPT) $(RUNNER_PART1) 100 0.20 0.05 log_view20_nodes100_xp5.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 500 0.20 0.05 log_view20_nodes500_xp1.csv 1240000
log_part09:
	$(ESCRIPT) $(RUNNER_PART1) 500 0.20 0.05 log_view20_nodes500_xp2.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 500 0.20 0.05 log_view20_nodes500_xp3.csv 1240000
log_part10:
	$(ESCRIPT) $(RUNNER_PART1) 500 0.20 0.05 log_view20_nodes500_xp4.csv 1240000
	$(ESCRIPT) $(RUNNER_PART1) 500 0.20 0.05 log_view20_nodes500_xp5.csv 1240000
	

### Byzantine Nodes
log_byz_perc_05:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.05 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_05_perc.csv $(WAIT_TIME)
log_byz_perc_06:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.06 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_06_perc.csv $(WAIT_TIME)
log_byz_perc_08:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.08 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_08_perc.csv $(WAIT_TIME)
log_byz_perc_10:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.10 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_10_perc.csv $(WAIT_TIME)
log_byz_perc_12:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.12 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_12_perc.csv $(WAIT_TIME)
log_byz_perc_14:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.14 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_14_perc.csv $(WAIT_TIME)
log_byz_perc_15:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.15 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_15_perc.csv $(WAIT_TIME)
log_byz_perc_16:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.16 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_16_perc.csv $(WAIT_TIME)
log_byz_perc_18:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.18 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_18_perc.csv $(WAIT_TIME)
log_byz_perc_20:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.20 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_20_perc.csv $(WAIT_TIME)
log_byz_perc_25:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.25 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_25_perc.csv $(WAIT_TIME)
log_byz_perc_30:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.30 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_30_perc.csv $(WAIT_TIME)
log_byz_perc_35:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.35 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_35_perc.csv $(WAIT_TIME)
log_byz_perc_40:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.40 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_40_perc.csv $(WAIT_TIME)
log_byz_perc_45:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.45 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_45_perc.csv $(WAIT_TIME)
log_byz_perc_50:
	$(ESCRIPT) $(RUNNER_PART2) 100 0.50 $(VIEW_FRAC) $(SUBSET_FRAC) log_byz_50_perc.csv $(WAIT_TIME)
log_byz_percs: log_byz_perc-10 log_byz_perc-20 log_byz_perc-30 log_byz_perc-40 log_byz_perc-50

## CLEAN
# This command clean the project by deleting output file
clean:
	@rm -f `find . -type f -name '*.beam'`
	@rm -f `find . -type f -name '*.dump'`
	@printf "All '*.beam' & '*.dump' files cleaned in the 'src' directory\n"


## ARCHIVING
@gen_part1:
	@mkdir ${DIR_NAME}/$(PART1_DIR)
	@$(foreach file,${MODULES_FILES},cp -r ${MODULES_DIR}/${file} ${DIR_NAME}/${PART1_DIR}/${file};)
	@$(foreach file,${PART1_FILES},cp -r ${PARTS_DIR}/${PART1_DIR}/${file} ${DIR_NAME}/${PART1_DIR}/${file};)
@gen_part2:
	@mkdir ${DIR_NAME}/$(PART2_DIR)
	@$(foreach file,${MODULES_FILES},cp -r ${MODULES_DIR}/${file} ${DIR_NAME}/${PART2_DIR}/${file};)
	@$(foreach file,${PART2_FILES},cp -r ${PARTS_DIR}/${PART2_DIR}/${file} ${DIR_NAME}/${PART2_DIR}/${file};)
zip:
	@mkdir ${DIR_NAME}
	@make @gen_part1
	@make @gen_part2
	@$(foreach file,${OTHER_FILES},cp -r ${file} ${DIR_NAME}/${file};)
	@git log --stat > ${DIR_NAME}/.gitlog.stat
	zip -r ${ZIP_NAME} ${DIR_NAME}
	@rm -r -d ${DIR_NAME}

.PHONY: clean zip build1 run1 build2 run2