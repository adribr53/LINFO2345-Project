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

MODULES_SRC_DIR = src/modules
PARTS_SRC_DIR = src/parts
PART1_DIR = 1_rps_implem
PART2_DIR = 2_byzantine_nodes_problem

# RUN
RUNNER_PART1 = $(PARTS_SRC_DIR)/$(PART1_DIR)/$(FILE_RUNNER)
RUNNER_PART2 = $(PARTS_SRC_DIR)/$(PART2_DIR)/$(FILE_RUNNER)

# ZIP
DIR_NAME = LINFO2345_GIOT_Adrien_JADIN_Guillaume
ZIP_NAME = ./$(DIR_NAME).zip
OTHER_FILES = README.md #report.pdf


## BUILDER
# This command take a Erlang source file and compile it to return a .beam file
MODULES_BUILD = $(MODULES_SRC_DIR)/$(FILE_NODE) $(MODULES_SRC_DIR)/$(FILE_VIEW) $(MODULES_SRC_DIR)/$(FILE_LOG)
build:
	$(ERLC) $(MODULES_BUILD) $(PARTS_SRC_DIR)/$(PART2_DIR)/$(FILE_BYZ_NODE)


## RUNNERS
run1:
	$(ESCRIPT) $(RUNNER_PART1) $(N_NODE) $(VIEW_FRAC) $(SUBSET_FRAC) $(LOG_FILE) $(WAIT_TIME)
	# OR
	# $(ESCRIPT) $(RUNNER_PART2) $(N_NODE) 0 $(VIEW_FRAC) $(SUBSET_FRAC) $(LOG_FILE) $(WAIT_TIME)
run2:
	$(ESCRIPT) $(RUNNER_PART2) $(N_NODE) $(BYZ_FRAC) $(VIEW_FRAC) $(SUBSET_FRAC) $(LOG_FILE) $(WAIT_TIME)


## CLEAN
# This command clean the project by deleting output file
clean:
	@rm -f `find . -type f -name '*.beam'`
	@rm -f `find . -type f -name '*.dump'`
	@printf "All '*.beam' & '*.dump' files cleaned in the 'src' directory\n"


## ARCHIVING
@gen_part1:
	@mkdir ${DIR_NAME}/$(PART1_DIR)
	@cp -r ${MODULES_SRC_DIR}/${FILE_NODE} ${DIR_NAME}/${PART1_DIR}/${FILE_NODE}
	@cp -r ${MODULES_SRC_DIR}/${FILE_VIEW} ${DIR_NAME}/${PART1_DIR}/${FILE_VIEW}
	@cp -r ${MODULES_SRC_DIR}/${FILE_LOG} ${DIR_NAME}/${PART1_DIR}/${FILE_LOG}
	@cp -r ${RUNNER_PART1} ${DIR_NAME}/${PART1_DIR}/${FILE_RUNNER}
	@cp -r $(PARTS_SRC_DIR)/$(PART1_DIR)/Makefile ${DIR_NAME}/${PART1_DIR}/Makefile
	@cp -r $(PARTS_SRC_DIR)/$(PART1_DIR)/README.md ${DIR_NAME}/${PART1_DIR}/README.md
@gen_part2:
	@mkdir ${DIR_NAME}/$(PART2_DIR)
	@cp -r ${MODULES_SRC_DIR}/${FILE_NODE} ${DIR_NAME}/${PART2_DIR}/${FILE_NODE}
	@cp -r ${MODULES_SRC_DIR}/${FILE_VIEW} ${DIR_NAME}/${PART2_DIR}/${FILE_VIEW}
	@cp -r ${MODULES_SRC_DIR}/${FILE_LOG} ${DIR_NAME}/${PART2_DIR}/${FILE_LOG}
	@cp -r ${RUNNER_PART2} ${DIR_NAME}/${PART2_DIR}/${FILE_RUNNER}
	@cp -r $(PARTS_SRC_DIR)/$(PART2_DIR)/${FILE_BYZ_NODE} ${DIR_NAME}/${PART2_DIR}/${FILE_BYZ_NODE}
	@cp -r $(PARTS_SRC_DIR)/$(PART2_DIR)/Makefile ${DIR_NAME}/${PART2_DIR}/Makefile
	@cp -r $(PARTS_SRC_DIR)/$(PART2_DIR)/README.md ${DIR_NAME}/${PART2_DIR}/README.md

zip:
	@mkdir ${DIR_NAME}
	@make @gen_part1
	@make @gen_part2
	@$(foreach file,${OTHER_FILES},cp -r ${file} ${DIR_NAME}/${file};)
	@git log --stat > ${DIR_NAME}/.gitlog.stat
	zip -r ${ZIP_NAME} ${DIR_NAME}
	@rm -r -d ${DIR_NAME}

.PHONY: clean zip build1 run1 build2 run2