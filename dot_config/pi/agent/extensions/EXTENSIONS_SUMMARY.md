# Pi Extensions Overview

This document provides a comprehensive overview of all available pi extensions, categorized by their primary functionality.

## Your Current Extensions

### 1. `debug-logger.js` (JavaScript)
**Purpose:** Logs model requests and responses to files for debugging
**Location:** `~/.local/share/pi/logs/`
**Features:**
- Captures `before_provider_request` events and logs full payload
- Captures `message_end` events for assistant messages
- Timestamped log files (max 20 per type)
- Logs directory auto-created if missing

### 2. `minimal.ts` (TypeScript)
**Purpose:** Minimal extension template demonstrating footer customization
**Features:**
- Shows how to use `ctx.ui.setFooter()` with custom rendering
- Demonstrates token tracking and git branch display in footer
- Currently has code commented out as a reference example

---

## Official Example Extensions

### Custom Tools & Tools Management

#### 1. **hello.ts** - Hello Tool
- Minimal custom tool example
- Registers a `hello` tool that greets by name
- Demonstrates basic tool registration with TypeBox parameters

#### 2. **dynamic-tools.ts** - Dynamic Tool Registration
- Shows how to register tools after session initialization
- Provides `/add-echo-tool <name>` command to add echo tools at runtime
- Tools can be added dynamically during a session without reload

#### 3. **todo.ts** - Todo List Manager
- Complete state management via session entries
- Registers `todo` tool with actions: list, add, toggle, clear
- Provides `/todos` command with custom UI component
- State persists across branches and sessions
- Custom rendering for both tool calls and results

#### 4. **tools.ts** - Tools Example
- Demonstrates multiple tool registrations
- Shows various parameter types and behaviors

### Event Handling & Lifecycle

#### 5. **event-bus.ts** - Event Bus
- Demonstrates `pi.events` API for inter-extension communication
- Shows how to emit and listen to custom events

#### 6. **file-trigger.ts** - File Change Detection
- Monitors file system changes during a session
- Triggers actions when specific files are modified

### User Interaction & UI Components

#### 7. **qna.ts** - Q&A Tool
- Interactive question/answer tool for user input
- Demonstrates collecting information via tools

#### 8. **question.ts** - Question Tool
- Similar to qna, asks questions during session

#### 9. **questionnaire.ts** - Questionnaire Flow
- Multi-step questionnaire wizard
- Shows complex interactive flows

#### 10. **modal-editor.ts** - Modal Editor
- Full-screen modal editor component
- Demonstrates custom text editing UI

#### 11. **interactive-shell.ts** - Interactive Shell
- Provides shell-like interaction within pi

#### 12. **notify.ts** - Notification Demo
- Shows various notification types and usage patterns

### Custom Rendering & Display

#### 13. **message-renderer.ts** - Message Renderer
- Custom rendering for specific message types
- Demonstrates `registerMessageRenderer()` API

#### 14. **built-in-tool-renderer.ts** - Built-in Tool Renderer
- Overrides default rendering for built-in tools like bash, read, write

#### 15. **custom-header.ts** - Custom Header
- Adds custom header to the TUI display

#### 16. **custom-footer.ts** - Custom Footer
- Shows footer customization with token stats and git branch

#### 17. **status-line.ts** - Status Line
- Displays status information in a dedicated line

#### 18. **widget-placement.ts** - Widget Placement
- Demonstrates different widget positions (above/below editor)

#### 19. **titlebar-spinner.ts** - Title Bar Spinner
- Shows animation/spinner in title bar during processing

#### 20. **rainbow-editor.ts** - Rainbow Editor
- Colorful text rendering demonstration
- Shows theme customization with colors

### Session Management & State

#### 21. **bookmark.ts** - Bookmarks
- Allows bookmarking session entries with labels
- Provides navigation to bookmarked points

#### 22. **session-name.ts** - Session Naming
- Sets custom display names for sessions
- Shows `pi.setSessionName()` and `pi.getSessionName()` APIs

#### 23. **reload-runtime.ts** - Runtime Reloading
- Demonstrates `/reload` command implementation
- Shows extension reloading without restarting pi

#### 24. **shutdown-command.ts** - Shutdown Control
- Provides custom shutdown/exit commands

### Git & Version Control Integration

#### 25. **git-checkpoint.ts** - Git Checkpoints
- Creates git stashes at each turn
- Offers to restore code state when forking sessions
- Integrates with fork functionality for safe experimentation

#### 26. **auto-commit-on-exit.ts** - Auto Commit on Exit
- Automatically commits changes before session exit
- Provides safety net for development work

#### 27. **dirty-repo-guard.ts** - Dirty Repository Guard
- Warns or blocks operations with uncommitted changes
- Prevents accidental loss of work

### Permission & Safety Guards

#### 28. **permission-gate.ts** - Permission Gate
- Prompts for confirmation before dangerous commands (rm -rf, sudo, chmod 777)
- Intercepts bash tool calls and requires user approval

#### 29. **protected-paths.ts** - Protected Paths
- Prevents writes to sensitive files/directories (.env, node_modules, etc.)
- Path-based access control for file operations

#### 30. **confirm-destructive.ts** - Destructive Action Confirmation
- General confirmation dialog for destructive operations
- Shows `ctx.ui.confirm()` usage pattern

### Input Processing & Transformation

#### 31. **input-transform.ts** - Input Transform
- Transforms user input before agent processing
- Demonstrates intercepting and rewriting prompts
- Can handle special prefixes or commands

### Games & Entertainment

#### 32. **snake.ts** - Snake Game
- Full playable snake game via `/snake` command
- Custom TUI component with keyboard controls (arrow keys, WASD)
- Saves state across pauses using session entries
- Score tracking and high score persistence

#### 33. **space-invaders.ts** - Space Invaders
- Classic arcade game implementation
- Demonstrates complex game loops in extensions

### Model & Provider Configuration

#### 34. **model-status.ts** - Model Status Display
- Shows current model information in UI
- Displays model selection changes via `model_select` event

#### 35. **minimal-mode.ts** - Minimal Mode
- Simplified mode for focused work
- Reduces UI clutter and distractions

#### 36. **custom-provider-anthropic/** - Custom Anthropic Provider
- Register custom API endpoints for Anthropic models
- Demonstrates `pi.registerProvider()` with full model definitions
- Includes OAuth support examples

#### 37. **custom-provider-gitlab-duo/** - GitLab Duo Provider
- Integration example for GitLab's AI service
- Shows provider registration for proprietary services

#### 38. **custom-provider-qwen-cli/** - Qwen CLI Provider
- Custom model provider setup for Alibaba/Qwen models

#### 39. **provider-payload.ts** - Provider Payload Inspection
- Logs and inspects provider request payloads
- Useful for debugging API interactions

### Advanced Patterns & Features

#### 40. **subagent/index.ts** + **agents.ts** - Sub-agent Pattern
- Creates child agents within the main session
- Demonstrates multi-agent workflows
- Shows how to delegate tasks to specialized sub-agents

#### 41. **handoff.ts** - Handoff Pattern
- Transfers control between different contexts or modes
- Shows state transfer and context switching

#### 42. **override-tool.ts** - Tool Override
- Overrides behavior of existing tools
- Demonstrates `tool_call` event interception for modification

#### 43. **trigger-compact.ts** - Compaction Trigger
- Programmatically triggers session compaction
- Shows how to manage context size

#### 44. **custom-compaction.ts** - Custom Compaction
- Provides custom summarization logic during compaction
- Demonstrates `session_before_compact` and `session_compact` events

### System Integration & OS Features

#### 45. **mac-system-theme.ts** - macOS System Theme Sync
- Syncs with macOS system appearance (light/dark mode)
- Dynamically updates theme based on system preferences

### Security & Authentication

#### 46. **claude-rules.ts** - Claude Rules Enforcement
- Applies specific rules for Claude model interactions
- Demonstrates rule-based behavior modification

#### 47. **hidden-thinking-label.ts** - Hidden Thinking Label
- Controls visibility of thinking/reasoning labels in UI
- Shows conditional rendering based on mode or settings

### SSH & Remote Operations

#### 48. **ssh.ts** - SSH Integration
- Extends bash operations to remote servers via SSH
- Demonstrates `user_bash` event interception

#### 49. **inline-bash.ts** - Inline Bash Commands
- Allows inline execution of shell commands
- Shows simplified command syntax and execution

### Debugging & Development Tools

#### 50. **rpc-demo.ts** - RPC Mode Demo
- Demonstrates extension behavior in RPC mode
- Shows UI protocol differences between interactive and RPC modes

#### 51. **overlay-test.ts** - Overlay Testing
- Tests overlay rendering components
- Useful for developing custom TUI overlays

#### 52. **overlay-qa-tests.ts** - QA Test Suite
- Quality assurance tests for overlay components
- Automated validation of UI behavior

### Bash & Shell Extensions

#### 53. **bash-spawn-hook.ts** - Bash Spawn Hook
- Intercepts bash process spawning
- Shows how to modify or log shell execution

### Theme & Appearance

#### 54. **pirate.ts** - Pirate Mode
- Transforms all output into pirate speak
- Demonstrates text transformation in tool results and messages

### File Operations

#### 55. **truncated-tool.ts** - Truncated Tool Demo
- Shows handling of truncated outputs
- Demonstrates pagination or chunking patterns

### Resource Discovery

#### 56. **dynamic-resources/index.ts** - Dynamic Resources
- Dynamically contributes skill, prompt, and theme paths
- Demonstrates `resources_discover` event for extending capabilities

### Sandbox & Isolation

#### 57. **sandbox/index.ts** - Sandbox Mode
- Provides isolated execution environment
- Shows sandboxed tool execution patterns

### Advanced Features

#### 58. **with-deps/index.ts** - Extension with Dependencies
- Demonstrates npm package dependencies in extensions
- Shows `package.json` setup for complex extensions

#### 59. **command.ts** - Command Examples
- Multiple command registration examples
- Shows argument completion and handling

### System Prompt & Context Manipulation

#### 60. **system-prompt-header.ts** - System Prompt Header
- Adds custom headers to system prompts
- Modifies agent behavior via prompt injection

### Image Generation & AI Features

#### 61. **antigravity-image-gen.ts** - Anti-gravity Image Generator
- Demonstrates image generation tool integration
- Shows handling of media types in tools

### Time-based Interactions

#### 62. **timed-confirm.ts** - Timed Confirmation
- Adds countdowns or timeouts to confirmations
- Shows time-sensitive user interactions

---

## Extension Categories Summary

| Category | Count | Examples |
|----------|-------|----------|
| Custom Tools | 5+ | todo, hello, dynamic-tools |
| Event Handlers | 10+ | event-bus, file-trigger |
| UI Components | 15+ | modal-editor, snake, rainbow-editor |
| Session Management | 8+ | bookmark, session-name, reload-runtime |
| Git Integration | 3+ | git-checkpoint, auto-commit-on-exit |
| Security/Safety | 4+ | permission-gate, protected-paths |
| Input Processing | 2+ | input-transform |
| Games/Entertainment | 2+ | snake, space-invaders |
| Model/Provider | 8+ | custom-provider-anthropic, model-status |
| Advanced Patterns | 10+ | subagent, handoff, override-tool |
| System Integration | 3+ | mac-system-theme, ssh |
| Debugging | 5+ | rpc-demo, overlay-test |

---

## Key Extension APIs Demonstrated

### Core APIs
- `pi.on(event, handler)` - Event subscription
- `pi.registerTool(definition)` - Custom tool registration
- `pi.registerCommand(name, options)` - Slash command registration
- `pi.sendMessage()` / `pi.sendUserMessage()` - Message injection
- `pi.appendEntry(type, data)` - Session persistence

### Context APIs
- `ctx.ui.notify()`, `confirm()`, `select()`, `input()`, `editor()`, `custom()`
- `ctx.sessionManager.getEntries()`, `getBranch()`, `getSessionFile()`
- `ctx.modelRegistry.find()`, `ctx.model`
- `ctx.signal` - Abort signal for async operations
- `ctx.compact()` - Trigger compaction

### Advanced APIs
- `pi.registerProvider(name, config)` - Custom model providers
- `pi.registerMessageRenderer(type, renderer)` - Custom message rendering
- `pi.registerShortcut(keybinding, options)` - Keyboard shortcuts
- `pi.registerFlag(name, options)` - CLI flags
- `pi.exec(command, args, options)` - Shell execution

---

## Extension Loading Order

1. Global extensions: `~/.pi/agent/extensions/*.ts` and subdirectories
2. Project-local extensions: `.pi/extensions/*.ts` and subdirectories
3. Extensions in `settings.json` packages/extensions arrays

Extensions load in alphabetical order within each location.

---

## Best Practices from Examples

1. **State Management**: Store state in tool result details for proper branching support
2. **Session Reconstruction**: Rebuild in-memory state on `session_start` events
3. **User Interaction**: Check `ctx.hasUI` before attempting UI operations
4. **Abort Handling**: Use `ctx.signal` or provided signal parameter for cancellable operations
5. **Error Handling**: Always handle errors gracefully, especially file I/O and network calls
6. **Resource Cleanup**: Dispose of timers, listeners, and other resources in `session_shutdown`
7. **Performance**: Cache computed values and invalidate on state changes

---

## Getting Started

To create your own extension:

1. Create a TypeScript/JavaScript file in `~/.pi/agent/extensions/`
2. Export a default function that receives `ExtensionAPI`
3. Subscribe to events using `pi.on()`
4. Register tools or commands as needed
5. Test with `/reload` command or restart pi

Example:
```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.notify("My extension loaded!", "info");
  });

  pi.registerTool({
    name: "mytool",
    label: "My Tool",
    description: "Does something useful",
    parameters: Type.Object({
      input: Type.String(),
    }),
    async execute(_id, params) {
      return { content: [{ type: "text", text: `Processed: ${params.input}` }] };
    },
  });
}
```

---

## Additional Resources

- **Documentation**: `/Users/rommel/.local/share/mise/installs/node/25.9.0/lib/node_modules/@mariozechner/pi-coding-agent/docs/extensions.md`
- **Extension API Types**: `@mariozechner/pi-coding-agent` package
- **TUI Components**: `@mariozechner/pi-tui` package
- **Session Management**: See session.md documentation

---

*Generated: 2026-04-05*
*Total Example Extensions: ~75 files across various categories*
