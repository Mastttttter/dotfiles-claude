# CLI Flags Reference

Source: `claude --help` (v2.1.163) cross-checked against [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference). Covers programmatic/headless and interactive-mode flags.

**Voice when editing**: descriptive cataloguing only. Each row matches the neutral tone of its siblings. Forbidden phrases: "useful for X", "critical for", "recommended for", "fire-and-forget", "scriptable from", "great for", or any audience-guidance / selling language. If a new row visibly stands out tonally from its neighbors, prune until it doesn't. Mirror docs phrasing where one exists; cite `--help` only for behavior the docs page omits.

## Core Headless Flags

| Flag | Description |
|---|---|
| `-p` / `--print` | Non-interactive mode; print response and exit |
| `--output-format text\|json\|stream-json` | Output format (default: `text`) |
| `--input-format text\|stream-json` | Input format for print mode (default: `text`) |
| `--model <model>` | Model alias (`sonnet`, `opus`) or full name (`claude-opus-4-8`) |
| `--verbose` | Full turn-by-turn output (needed with `stream-json` for event details) |
| `--include-partial-messages` | Stream token-level partial events; requires `-p` + `stream-json` |
| `--include-hook-events` | Emit hook lifecycle events into output stream; requires `stream-json` |
| `--replay-user-messages` | Re-echo stdin user messages on stdout; requires both `--input-format stream-json` and `--output-format stream-json` |
| `--bare` | Skip auto-discovery of CLAUDE.md, hooks, skills, plugins, MCP servers, auto-memory, and OAuth/keychain reads. Sets `CLAUDE_CODE_SIMPLE=1`. See `auth.md` |
| `--betas <betas...>` | Beta API headers (API key users only), e.g. `interleaved-thinking` |
| `--effort low\|medium\|high\|xhigh\|max` | Effort level for the current session |
| `--brief` | Enable the `SendUserMessage` tool for agent-to-user communication |
| `--prompt-suggestions [value]` | Emit a `prompt_suggestion` message predicting the next user prompt; requires `-p` + `stream-json` |

## Permission Control

| Flag | Description |
|---|---|
| `--permission-mode <mode>` | `default\|acceptEdits\|plan\|auto\|dontAsk\|bypassPermissions` |
| `--allowedTools` / `--allowed-tools "Bash(git:*) Edit"` | Pre-approve specific tools (space or comma separated) |
| `--disallowedTools` / `--disallowed-tools "..."` | Deny specific tools |
| `--tools "..."` | Restrict to only these tools (`""` disables all, `"default"` enables all) |
| `--dangerously-skip-permissions` | Bypass all permission checks (sandboxed environments only) |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to the `Shift+Tab` mode cycle without starting in it (e.g. begin in `plan`, switch later) |
| `--permission-prompt-tool <mcp-tool>` | Delegate permission prompts to an MCP tool. Hidden flag |

## Budget Control

| Flag | Description |
|---|---|
| `--max-budget-usd <amount>` | Maximum USD spend (print mode only) |
| `--max-turns N` | Limit agentic turns (print mode only). Hidden flag — not in `--help` but works |
| `--fallback-model <model>` | Fallback model when default is overloaded (print mode only) |

## Session Management

| Flag | Description |
|---|---|
| `-c` / `--continue` | Continue most recent conversation in cwd |
| `-r` / `--resume [value]` | Resume by session ID/name, or open picker |
| `--fork-session` | Branch into new session ID when resuming |
| `--no-session-persistence` | Don't write session to disk (print mode only) |
| `--session-id <uuid>` | Use a specific session UUID |
| `-n` / `--name <name>` | Name the session for later `--resume <name>` |
| `--from-pr [value]` | Resume session linked to a PR |
| `--bg [prompt]` | Start a supervisor-hosted background session; `--exec <cmd>` runs a shell job instead. See `agent-view.md` |

## System Prompt and Context

| Flag | Description |
|---|---|
| `--system-prompt "..."` | Replace default system prompt entirely |
| `--system-prompt-file <path>` | Same, from file. Hidden flag |
| `--append-system-prompt "..."` | Append to default system prompt |
| `--append-system-prompt-file <path>` | Same, from file. Hidden flag |
| `--settings <path-or-json>` | Load additional settings |
| `--mcp-config <configs...>` | Load MCP servers from JSON files or strings |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`, ignore all others |
| `--agents <json>` | Define subagents dynamically |
| `--agent <agent>` | Agent for the current session (overrides setting) |
| `--add-dir <directories...>` | Grant file access to additional directories |
| `--exclude-dynamic-system-prompt-sections` | Move machine-specific sections to first user message (improves cross-user cache reuse) |
| `--plugin-dir <path>` | Load plugins from a directory or `.zip` archive for this session only (repeatable) |
| `--plugin-url <url>` | Fetch a plugin `.zip` from a URL for this session only (repeatable) |
| `--disable-slash-commands` | Disable all skills |
| `--setting-sources <user,project,local>` | Comma-separated list of settings tiers to load |

## Structured Output

| Flag | Description |
|---|---|
| `--json-schema '<schema>'` | Validate output against JSON Schema; result in `structured_output` field |

## File and Resource

| Flag | Description |
|---|---|
| `--file <specs...>` | File resources to download at startup. Format: `file_id:relative_path` (in `--help`, undocumented in public CLI reference page) |

## Worktree and IDE

| Flag | Description |
|---|---|
| `-w` / `--worktree [name]` | Create a new git worktree for this session |
| `--tmux` | Create tmux session for worktree (requires `--worktree`) |
| `--ide` | Auto-connect to IDE on startup |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |

## Remote Control

| Flag | Description |
|---|---|
| `--remote-control [name]` | Start an interactive session with Remote Control enabled so it can also be driven from claude.ai or the Claude app |
| `--remote-control-session-name-prefix <prefix>` | Prefix for auto-generated Remote Control session names (default: hostname). Same as `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` |

## Init Hooks

| Flag | Description |
|---|---|
| `--init` | Run initialization hooks then start interactive mode |
| `--init-only` | Run initialization hooks and exit (no interactive session) |
| `--maintenance` | Run maintenance hooks then start interactive mode |

## Debug

| Flag | Description |
|---|---|
| `-d` / `--debug [filter]` | Debug mode with optional category filter (e.g., `"api,hooks"`) |
| `--debug-file <path>` | Write debug logs to file |
| `--mcp-debug` | Deprecated; use `--debug` |
| `-v` / `--version` | Print CLI version and exit |

## CLI Subcommands (headless-relevant)

| Command | Purpose |
|---|---|
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts (subscription auth). Prints to stdout, does not save |
| `claude auth status` | Check login state — exits `0` if logged in, `1` otherwise. `--text` for human-readable; default JSON |
| `claude auth login [--console] [--sso] [--email <addr>]` | Sign in. `--console` uses Anthropic Console (API billing) instead of subscription |
| `claude auth logout` | Log out |
| `claude update` | Update CLI to latest (alias `upgrade`) |
| `claude install [target]` | Install Claude Code native build (`stable`, `latest`, or a specific version) |
| `claude doctor` | Check auto-updater health (spawns `.mcp.json` stdio servers for health checks) |
| `claude project purge [path]` | Delete all Claude Code state for a project (transcripts, tasks, file history, config entry) |
| `claude ultrareview [target]` | Run a cloud-hosted multi-agent code review of the current branch (or a PR number / base branch) and print findings |
| `claude agents` | Manage background agents (agent-view TUI); `--json` lists live sessions for scripting. See `agent-view.md` |
| `claude auto-mode defaults` | Print built-in auto-mode classifier rules as JSON. `claude auto-mode config` prints the effective config with settings applied; `claude auto-mode critique` gets AI feedback on custom rules |
| `claude mcp` | Manage MCP servers (see [MCP documentation](https://code.claude.com/docs/en/mcp) for subcommands) |
| `claude plugin <subcmd>` | Manage plugins (alias: `plugins`, see [plugin reference](https://code.claude.com/docs/en/plugins-reference#cli-commands-reference) for subcommands) |

## Hidden Flags (NOT in v2.1.163 `--help`, but documented in CLI reference page)

The official docs note: *"`claude --help` does not list every flag, so a flag's absence from `--help` does not mean it is unavailable."* These flags work but are not shown by `claude --help`:
- `--max-turns N` — limit agentic turns
- `--permission-prompt-tool <mcp-tool>` — delegate permission prompts to MCP
- `--system-prompt-file <path>` — system prompt from file
- `--append-system-prompt-file <path>` — append system prompt from file
- `--init`, `--init-only`, `--maintenance` — init/maintenance hook entry points

## Dropped from `--help` by v2.1.163 (still functional)

Listed in `--help` at v2.1.116; no longer shown at v2.1.163 but still accepted (verified by probe). Treat as de-emphasized preview surfaces, not stable APIs:
- `--remote "<task>"` — create a new web session on claude.ai with the given task
- `--teleport` — resume a claude.ai web session in the local terminal
- `--rc [name]` — alias of `--remote-control`
- `--teammate-mode <auto\|in-process\|tmux>` — display mode for agent-team teammates (preview)
- `--channels <plugin:name@market...>` — listen for MCP channel notifications (requires claude.ai auth)
- `--dangerously-load-development-channels` — enable channels outside the approved allowlist (local dev)
- `claude remote-control` (subcommand) — start a Remote Control server with no local interactive session
