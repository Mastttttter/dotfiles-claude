# Agent View — Background Sessions

`claude agents` opens one screen managing every background session a per-user **supervisor** hosts: dispatch tasks, watch state, peek/reply, attach for the full conversation. Sessions keep running with no terminal attached and persist across supervisor restarts and machine sleep (not shutdown).

Research preview; requires Claude Code v2.1.139+. Distinct from headless `-p`: agent view is interactive multi-session management, not a scripted one-shot stream. Turn off with `disableAgentView` setting or `CLAUDE_CODE_DISABLE_AGENT_VIEW`.

## Start a background session

```bash
claude --bg "investigate the flaky SettingsChangeDetector test"   # straight to background
claude --bg --name "flaky-fix" "<prompt>"                          # set display name
claude --bg --agent code-reviewer "address review comments on PR 1234"
claude --bg --exec 'pytest -x'                                     # shell job, no model invoked
```

Prints a short ID (also the dir name under `~/.claude/jobs/`):
```text
backgrounded · 7c5dcf5d · flaky-test-fix
```

From inside an interactive session: `/background` (alias `/bg`), optionally with a follow-up instruction (`/bg run tests and fix failures`). `←` on an empty prompt backgrounds the current session and opens agent view. `/stop` ends a session from inside it.

## Shell management commands

| Command | Purpose |
|---|---|
| `claude agents` | Open agent view (TUI) |
| `claude agents --cwd <path>` | Scope list to sessions under `<path>` (v2.1.141+) |
| `claude agents --json` | Print live sessions as JSON array and exit (scriptable) |
| `claude attach <id>` | Attach in this terminal |
| `claude logs <id>` | Print recent output |
| `claude stop <id>` | Stop a session (alias `claude kill`) |
| `claude respawn <id>` / `--all` | Restart with conversation intact (e.g. pick up new binary) |
| `claude rm <id>` | Remove from list; keeps a dirty worktree and prints its path |
| `claude daemon status` | Supervisor PID, version, socket dir, worker count |
| `claude daemon stop --any [--keep-workers]` | Stop supervisor; `--keep-workers` leaves sessions running for reconnect |

`--json` entries carry `pid`, `cwd`, `kind`, `startedAt`, plus `sessionId`/`name`/`status`; when `status` is `waiting`, `waitingFor` says what it's blocked on (`permission prompt`, `input needed`). This is the scripting surface — pair `--json` + `--cwd` to poll your own sessions without the TUI.

## TUI essentials

Sessions group by state: `Ready for review` (open PR) / `Needs input` above `Working` / `Completed` (finished+failed+stopped). Dispatch prompt at the bottom — every Enter starts a *new* session, not a follow-up.

| Key | Action |
|---|---|
| `Space` | Peek panel (latest output / the question), reply inline, number-key to answer multiple-choice |
| `Enter` / `→` | Attach (full session); `Shift+Enter` dispatch+attach |
| `←` | Detach back to table (never stops the session) |
| `Ctrl+T` | Pin — keeps process alive while idle |
| `Ctrl+X` ×2 | Stop then delete (deletes Claude-created worktree + uncommitted changes) |
| `Ctrl+S` | Toggle group by state / directory |

Dispatch-input prefixes: `<agent> …` / `@agent` run a subagent as main agent; `@repo` targets a sibling repo; `! cmd` runs a shell job; `#<n>`/PR-URL selects the session on that PR.

Defaults for dispatched sessions: `claude agents --permission-mode plan --model opus --effort high --agent <name>`. `bypassPermissions`/`auto` refused until accepted once interactively.

Row summaries are Haiku-class generated (billed; refresh ≤15s) — `ANTHROPIC_DEFAULT_HAIKU_MODEL` sets the model on third-party providers.

## Worktree isolation

Before its first edit, a background session moves into a git worktree under `.claude/worktrees/` so parallel sessions don't clobber each other. Skipped if already in a linked worktree, not a git repo (no `WorktreeCreate` hook), or the write is outside cwd. Disable per-repo with `worktree.bgIsolation: "none"` (v2.1.143+). Deleting a session in the TUI removes its Claude-created worktree **including uncommitted changes** — commit/push first.

## State & hosting

State icon color = task state (working/needs-input/idle/completed/failed/stopped); icon shape = process liveness (`✻`/`✽` alive · `∙` exited, restarts on next interaction · `✢` `/loop` sleeping). State persists on disk under `~/.claude/jobs/<id>/state.json`; roster in `~/.claude/daemon/roster.json`; `CLAUDE_CONFIG_DIR` gives a separate supervisor instance.

Supervisor stops a finished, unattached session's process after ~1h (pinned exempt), restarting it on next peek/reply/attach. Each session has `CLAUDE_JOB_DIR` set; `$CLAUDE_JOB_DIR/tmp` is a permission-free scratch dir.

## vs claude-dm

Agent view manages **your own supervisor-hosted** background sessions. It does **not** address independent peer Claude sessions in other tmux panes (colleagues', or interactive sessions not yet backgrounded) — that's the `claude-dm` skill's domain (peer messaging, safety gates, modal answering, slash-command injection). Complementary, not a replacement.
