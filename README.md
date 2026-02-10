# Agent Communication Protocol SDK for Swift

`swift-acp` is a high-performance Swift SDK for the [Agent Communication Protocol (ACP)](https://agentcommunicationprotocol.dev), designed to bridge the gap between Apple platforms and AI coding agents.

Built with Swift 6 and modern concurrency, it provides a seamless type-safe interface to connect, communicate, and collaborate with AI agents like Claude Code, Gemini, and others.

---

## ⚡️ Key Features

- **🚀 Multi-Transport Support**: Connect via local subprocess (`ProcessTransport`) or remote servers (`HTTPTransport`).
- **🛡️ Native Delegate API**: Handle permissions, file operations, and tool calls with a clean, async-await delegate pattern.
- **🛠️ Client-Side Tools**: Expose your app's functions as tools the agent can call directly.
- **📂 File System Integration**: Let agents read and write files safely within your app's sandbox.
- **🤖 Claude Code First-Class Support**: Typed metadata for Claude Code options (`autoApproveTools`, `maxParallelToolCalls`, etc).
- **⏱️ Performance Logging**: Built-in timing and batching for high-throughput coding tasks.
- **🔌 MCP Bridge**: Includes a minimal MCP server implementation for tool exposure to standard MCP clients.

---

## 📦 Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/i-am-bee/acp.git", branch: "main")
]
```

## 🚀 Quickstart

### 1. Connecting to a Local Agent (e.g., Claude Code)

```swift
import ACP

let client = ACPClient(
    command: "claude",
    arguments: ["--acp"],
    clientInfo: ClientInfo(name: "MyIDE", version: "1.0")
)

try await client.connect()
let session = try await client.newSession(workingDirectory: URL(fileURLWithPath: "/path/to/project"))

let response = try await client.prompt("Explain the architecture of this project")
print(response.stopReason)
```

### 2. Implementing the Delegate

Most interaction happens through `ACPClientDelegate`. Assign it to handle agent requests.

```swift
class AppAgentHandler: ACPClientDelegate {
    // Handle status updates (streaming text, plans, tools)
    func client(_ client: ACPClient, didReceiveUpdate update: SessionUpdate) {
        if let chunks = update.messageChunks {
            for chunk in chunks {
                print(chunk.text ?? "", terminator: "")
            }
        }
    }

    // Handle security permissions
    func client(_ client: ACPClient, requestPermission request: RequestPermissionRequest) async -> PermissionOptionID {
        // Return "allow_once", "allow_always", "reject_once", etc.
        return "allow_once"
    }

    // Provide tools to the agent
    func listTools(_ client: ACPClient) async -> [ToolDefinition] {
        return [
            ToolDefinition(
                name: "reveal_in_finder",
                description: "Reveals a file in macOS Finder",
                parameters: ["path": AnyCodable("string")]
            )
        ]
    }
}
```

---

## 💎 Advanced Capabilities

### Claude Code Optimization
Configure Claude Code specific behaviors via typed metadata:

```swift
let meta = ClaudeCodeMeta.autoApprove(except: ["rm", "git_push"])
try await client.newSession(meta: meta.toDictionary())
```

### Model & Mode Switching
Agents often support multiple modes (e.g., `architect`, `code`, `ask`) and models.

```swift
// Switch model mid-session
try await client.setSessionModel("claude-3-5-sonnet-20241022")

// Switch session mode
try await client.setSessionMode("architect")
```

### Performance & Debugging
Enable verbose logging or timing by setting environment variables:

- `ACP_VERBOSE=1`: Detailed JSON-RPC message logs.
- `ACP_TIMING=1`: Performance metrics for prompt response times and tool execution.
- `ACP_BATCHING=1`: Enables message chunk batching for smoother UI updates.

---

## 🧱 Project Structure

- `Sources/ACP`: Core SDK logic.
  - `Client`: Main `ACPClient` and delegate protocols.
  - `Protocol`: Type-safe models for ACP 0.3.0.
  - `Transport`: IPC (Process) and Network (HTTP) communication layers.
  - `Server`: Minimal `MCPServer` actor for exposing tools to other clients.

---

## 🗺️ API Comparison

| Feature | `swift-acp` | Other SDKs |
|---------|:---:|:---:|
| **Language Support** | Swift 6 / Apple Platforms | Python / TS |
| **Local Process (IPC)** | ✅ (Native) | ❌ |
| **HTTP Transport** | ✅ | ✅ |
| **Async/Await Native** | ✅ | ✅ |
| **Tool Registration** | ✅ | ✅ |
| **FileSystem Ops** | ✅ | ✅ |
| **Claude Metadata** | ✅ | ❌ |
| **MCP Bridge** | ✅ (Built-in) | ❌ |

---

## 📄 License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

---

> [!TIP]
> Developed for **Preflight** – The next-gen spatial AI IDE for Apple Vision Pro.

