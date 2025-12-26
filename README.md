# Agent Communication Protocol SDK for Swift

`swift-acp` helps developers to serve and consume agents over the Agent Communication Protocol. Built with Swift 6, it enables seamless integration between Apple platforms and AI coding agents.

---

## Prerequisites

- ✅ Swift >= 6.0
- ✅ macOS 15+ / iOS 18+ / visionOS 2+

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/i-am-bee/acp.git", branch: "main")
]
```

## Quickstart

### Process Transport (Local CLI Agents)

For connecting to local agents like Claude Code:

```swift
import ACP

let client = ACPClient(
    command: "claude",
    arguments: ["--acp"],
    clientInfo: ClientInfo(name: "MyIDE", version: "1.0")
)

try await client.connect()
let sessionId = try await client.newSession()
let response = try await client.prompt("Analyze the current directory")
```

### HTTP Transport (Remote Servers)

For connecting to remote ACP servers:

```swift
import ACP

let serverURL = URL(string: "http://localhost:8000")!
let client = ACPClient(
    serverURL: serverURL,
    clientInfo: ClientInfo(name: "MyApp", version: "1.0")
)

try await client.connect()
let sessionId = try await client.newSession()
let response = try await client.prompt("Hello, agent!")
```

### Handling Agent Actions

Implement `ACPClientDelegate` to handle the agent's interaction with your app:

```swift
class MyAgentHandler: ACPClientDelegate {
    func client(_ client: ACPClient, didReceiveUpdate update: SessionUpdate) {
        // Handle streaming text, tool progress, and plans
    }

    func client(_ client: ACPClient, requestPermission request: RequestPermissionRequest) async -> PermissionOptionID {
        // Show a native dialog: allow_once, allow_always, reject
        return "allow_once"
    }
}
```

---

## Transport Options

| Transport | Use Case | Constructor |
|-----------|----------|-------------|
| **Process** | Local CLI agents (claude, gemini) | `ACPClient(command:...)` |
| **HTTP** | Remote ACP servers | `ACPClient(serverURL:...)` |

---

## API Comparison

| Feature | Swift | Python | TypeScript |
|---------|-------|--------|------------|
| **Client class** | `ACPClient` | `Client` | `Client` |
| **Server class** | — | `Server` | — |
| **Process transport** | ✅ | — | — |
| **HTTP transport** | ✅ | ✅ | ✅ |
| **Connect** | `connect()` | Context manager | Context manager |
| **Run agent** | `prompt()` | `run_sync()` | `runSync()` |
| **Session mgmt** | ✅ | — | — |
| **Model switching** | ✅ | — | — |
| **Cancel** | ✅ | — | — |
| **Permissions** | Delegate | — | — |

---

> [!TIP]
> Explore the full API in the [ACP documentation](https://agentcommunicationprotocol.dev).

---

## Related SDKs

- [Python SDK](https://github.com/i-am-bee/acp/tree/main/python)
- [TypeScript SDK](https://github.com/i-am-bee/acp/tree/main/typescript)

---

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
