# make <task> [args] runs mise run <task> [args]: the first goal is the task name, the
# rest are its arguments. A flag that begins with - is eaten by make, so pass it as ARGS:
#   make test                      ->  mise run test
#   make lint ARGS="--verbose"     ->  mise run lint --verbose
TASK := $(firstword $(MAKECMDGOALS))
TASK_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

.PHONY: setup $(TASK) $(TASK_ARGS)

# The one target make owns: install the pinned tools.
# Every other command is a task in .mise/tasks.toml — list them with: mise tasks
setup:
	@command -v mise >/dev/null || { echo "make setup: mise is not installed — see https://mise.jdx.dev/getting-started.html"; exit 1; }
	@mise trust -q
	@mise install

ifneq ($(TASK),)
ifneq ($(TASK),setup)
$(TASK):
	@mise run $(TASK) $(TASK_ARGS) $(ARGS)
endif
endif

# Without a no-op rule, make would try to build the argument goals as targets.
ifneq ($(TASK_ARGS),)
$(TASK_ARGS):
	@:
endif
