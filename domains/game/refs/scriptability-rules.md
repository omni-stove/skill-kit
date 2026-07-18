# Scriptability rules — keep the project drivable without a GUI

The agent working this repo has **no access to the engine's GUI** — no Editor window, no
Inspector, no scene view, no drag-and-drop, no clicking Play. It can only read/write
files, run shell commands, and (if wired) call an engine-control MCP. Any setup that
exists *only* as GUI state the agent can't reproduce is a dead end. These rules keep the
project reproducible from code so the agent — and CI — can build, wire, run, and verify it.

Engine specifics below are Unity examples; the principle is engine-agnostic — every
engine has a GUI-only path and a code/CLI path, and this repo prefers the latter.

## 1. Run and test headless, not through the Editor

- Prefer the headless / batch-mode launch (`headless_cmd` in `engine.sh`) for running the
  game, executing a method, or running tests — no GUI needed, works in CI, output goes to
  a log the agent can read.
  - Unity: `<Unity> -batchmode -nographics -projectPath . -runTests` /
    `-executeMethod <Class.Method> -logFile - -quit`.
- Keep an editor-menu action mirrored by an `-executeMethod` entry point so anything a
  human would click can also be triggered from the shell.
- Never claim something "works" from a state only visible in the Game view — assert it via
  a log line, a test, or a written artifact the agent can inspect.

## 2. Wire object references in code, not in the Inspector

Hand-dragging references into serialized fields in the Inspector produces state that lives
only inside a `.unity` / `.prefab` binary the agent can't edit or reproduce. Avoid
depending on it. In order of preference:

1. **Resolve dependencies in code at runtime** — `GetComponent<T>()`,
   `GetComponentInChildren<T>()`, `FindAnyObjectByType<T>()`, `Resources.Load` /
   Addressables, a code composition root / service locator / DI container. The wiring is
   in a `.cs` file the agent owns.
2. **Build the object graph from script** — construct prefabs/scenes, add components, and
   set fields in an editor script or a runtime bootstrap, so the graph is defined by code,
   not by clicks.
3. **If a serialized reference is genuinely required**, set it via an editor script exposed
   as an `-executeMethod` entry point (agent runs it headless) — not by manual drag. Treat
   the serialized value as generated output, not hand-authored state.

Corollary: prefer `[SerializeField]` fields that a bootstrap fills in over ones a human
must populate; give every such field a code path that can (re)assign it.

## 3. Keep scene/asset state minimal and code-generated

- Construct test and demo setups in code (a bootstrap scene that spawns what it needs)
  rather than in hand-authored scenes the agent can't modify.
- Anything the agent must be able to change should live in text it can edit — `.cs`,
  config, data files — not baked into a binary scene/prefab.

## 4. Observe through logs, not the screen

- The agent can't watch the Game view. Instrument with `Debug.Log` (tagged, e.g.
  `[Combat]`) so behaviour is verifiable from the runtime log.
- Prefer deterministic, logged outcomes over "you'll see it on screen".

## When a GUI step is unavoidable

Some engine operations have no code path. When you hit one, do NOT fake it: state plainly
that this step requires the GUI, give the user the exact clicks, and — where possible —
add a scripted entry point (editor menu + `-executeMethod`) so the next time it's
automatable. Record the limitation rather than pretending the step ran.
