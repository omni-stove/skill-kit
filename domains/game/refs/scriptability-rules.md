# Rules for working the engine

Check which way you reach the engine's editor: `sh -c '. .agents/refs/engine.sh; control_mcp'`.
When it names the Computer Use tools (`mcp__computer-use__` or `mcp__remote-devices__computer_`)
and they are in this session, follow "Operating the editor"; otherwise follow "Without the
editor". Engine specifics below are Unity examples; apply the same split to any engine.

## Operating the editor

Work in the editor as its developer would, through the Computer Use tools: build and arrange
scenes, add components and set fields and references in the Inspector, press Play and play the
game with clicks and keys, and stop Play Mode when done.

- Judge a change by the screen as well as the log: after each change, play the affected flow
  and screenshot the Game view; check what the player sees — layout, motion, timing, feel —
  and fix what looks wrong before calling it done.
- Read errors in the Console window or the runtime log.
- Save the scene and prefabs after editing them, then confirm with `git status` that the
  change landed in files.
- Write game logic in code; use the editor for scenes, assets, wiring and play-testing.
- Run tests headless with `headless_cmd`.
- Under an access tier below full, typing and dragging in the editor are blocked; do those
  steps through code or an editor script, or hand them to the user.

## Without the editor

You can read and write files, run shell commands, and call an engine-control MCP when one is
wired. Keep the project buildable, wirable and verifiable from code.

- Run the game, execute a method and run tests with `headless_cmd` (Unity
  `<Unity> -batchmode -nographics -projectPath . -logFile - -quit [-runTests | -executeMethod <Class.Method>]`),
  and mirror every editor-menu action with an `-executeMethod` entry point.
- Wire references in code: resolve them at runtime (`GetComponent<T>()`,
  `FindAnyObjectByType<T>()`, `Resources.Load`, Addressables, a composition root), or build the
  object graph from a bootstrap or editor script. Set a serialized reference that must exist
  through an editor script run with `-executeMethod`, and give every `[SerializeField]` a code
  path that can reassign it.
- Build test and demo setups in a bootstrap scene that spawns what it needs; keep what you must
  change in `.cs`, config or data files.
- Verify through a tagged `Debug.Log` line (e.g. `[Combat]`), a test, or a file you can read —
  never from what only the Game view would show.
- When a step has no code path, tell the user it needs the editor, give the exact clicks, and
  add a scripted entry point (editor menu + `-executeMethod`) where you can.
