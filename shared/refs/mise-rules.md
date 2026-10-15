# mise and make rules

Every tool the repo runs is listed under `[tools]` in `mise.toml` by its major version (`node = "26"`), and `mise install` is what installs it. List a tool there before calling it. Propose the latest major (`mise latest <tool>`, major part only) and write a narrower version only when the user or the repo asks for one.

A tool that runs as its own binary goes under `[tools]`. A tool that runs on a runtime, or loads plugins or configs from a package registry, goes in the package manager's dev dependencies, and its task calls it through the package manager.

Every command a person or agent runs in the repo is a mise task in `.mise/tasks.toml`, which `mise.toml` pulls in through `[task_config] includes`. Give each task a lowercase dashed name and a `description`. Take arguments through `usage` (`arg "<id>"` gives `$usage_id`, `flag "--limit <limit>"` gives `$usage_limit`). When tasks differ only in env values, write one `[task_templates.<name>]` in `mise.toml` and have each task `extends` it with its own `env`.

`make <task> [args]` is `mise run <task> [args]`: the Makefile forwards its first goal as the task name and the remaining goals as arguments, and `ARGS="--flag"` carries anything that begins with `-`. The Makefile owns one target, `setup`, which runs `mise trust`, `mise install`, then `mise run setup`. Write every other command as a task, never as a Makefile target.

The `install` task installs the repo's dependencies. The `setup` task depends on it, then installs skill-kit and runs `skill-kit <domain> sync` for this repo's domain. The `update` task runs `skill-kit <domain> update`. The `lint` and `test` tasks are the entry points CI and the agent workflows call.

CI installs the tools with `jdx/mise-action`, runs `mise run install`, then `make lint` and `make test`; `make setup` stays with a developer's clone.
