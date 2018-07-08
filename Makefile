IMAGE := docker-tex
WHEN_CHANGED_VERSION := $(shell when-changed -v 2>/dev/null)

.PHONY: help
help:
	@echo "Prerequisites: " 
	@echo "	- python module 'when-changed' installed (ideally via pip)"
	@echo "	  found at https://github.com/joh/when-changed"
	@echo ""
	@echo "Commands (use with make):"
	@echo "	- build: create a docker image named '${IMAGE}'"
	@echo "\t\tmay take a couple of minutes fetching the texlive-full package"
	@echo "\t\tcontaining all texlive packages (it downloads ~2GB as of Debian 9)"
	@echo ""
	@echo "	- run: execute a given command (passed with ARGS env) to the previously"
	@echo "\t\tcreated image."
	@echo "\t\tExample: ARGS='pdftex doc.tex' make run"
	@echo ""
	@echo "\t\tExample where target tex file does not reside in current directory: "
	@echo "\t\t\tDIR=/path/to/dir ARGS='pdftex file.tex' make run"
	@echo ""
	@echo "	- watch: uses the python module when-changed watching the changes of a"
	@echo "\t\tgiven file passed executing a given command (ideally a typesetting engine)"
	@echo "\t\tExample: DIR=/path/to/dir/ FILE=file.tex ENGINE=xelatex make watch"
	@echo ""
	@echo "\t\tNote that a file and an engine must be passed. Otherwise it won't work"
	@echo ""

.PHONY: build
build:
	docker build -t ${IMAGE} .

.PHONY: run
run: env-ARGS
	@if [ "${DIR}" = "" ]; then \
		DIR=$(shell pwd); \
	fi

	docker run --rm \
		--user="$(shell id -u):$(shell id -g)" \
		-v ${DIR}:/home/tex \
		${IMAGE} ${ARGS}

# run by "DIR=/path/to/dir/ FILE=file.tex ENGINE=xelatex make watch"
.PHONY: watch
watch: env-FILE env-ENGINE
	@if [ "${WHEN_CHANGED_VERSION}" = "" ]; then \
		echo "[ERROR] when-changed appears to be not found in your system"; \
		exit 1; \
	fi

	@if [ "${DIR}" = "" ]; then \
		DIR=$(shell pwd); \
	fi

	@when-changed ${DIR}/*.tex -c "make run ARGS='${ENGINE} ${FILE}'"

# environmental var guard which protects rules
# kudos to https://stackoverflow.com/a/7367903
env-%: ENV
	@if [ "${${*}}" = "" ]; then \
		echo "[ERROR] Environment variable $* not set"; \
		exit 1; \
	fi

# prevent breakage of env-% if file already exists
# kudos to https://gist.github.com/brimston3/fc43658bdb6882ed13d942fa584dd2de
.PHONY: ENV
ENV: