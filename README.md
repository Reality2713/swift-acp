# swift-acp 🤖

> **The canonical Swift SDK for the Agent Client Protocol (ACP).**

`swift-acp` provides a native, high-level implementation of the [Agent Client Protocol](https://agentclientprotocol.com/) for macOS, iOS, and visionOS. It is designed to be the canonical bridge between Apple's platforms and AI coding agents (Claude Code, Gemini CLI, etc.).

---

## Why swift-acp?

Native AI coding agents require a robust, asynchronous transport layer to communicate with host applications. `swift-acp` handles the heavy lifting:

- 🚀 **Asynchronous Transport**: Clean `async/await` API for all JSON-RPC 2.0 communications.
- 🛠️ **Full Protocol Support**: Implements the complete ACP specification (sessions, prompts, tool calls, streaming).
- 🛡️ **Permission System**: Type-safe callbacks for user-in-the-loop authorization.
- 🍏 **Platform Optimized**: Built with Swift 6 and designed for modern Apple platform concurrency.

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/elkraneo/swift-acp.git", branch: "main")
]
```

---

## Quick Start

```swift
import ACP

// 1. Create a client (e.g., for Claude Code)
let client = ACPClient(
    command: "claude",
    arguments: ["--acp"],
    clientInfo: ClientInfo(name: "MyIDE", version: "1.0")
)

// 2. Connect and initialize
try await client.connect()

// 3. Create a session in your project root
let projectURL = URL(fileURLWithPath: "/path/to/project")
let sessionId = try await client.newSession(workingDirectory: projectURL)

// 4. Send a prompt
let response = try await client.prompt("Analyze the current directory")
```

---

## Handling Agent Actions

Implement `ACPClientDelegate` to handle the agent's interaction with your app.

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

## Requirements

- macOS 15+ / iOS 18+ / visionOS 2+
- Swift 6.0+

## Architecture

`swift-acp` uses a multi-layered approach to ensure thread safety and performance:

1.  **ACPClient**: The high-level interface (MainActor-isolated) for your UI.
2.  **ProcessTransport**: An actor-based layer managing the underlying shell process and JSON-RPC stream.

## License

MIT © [elkraneo](https://github.com/elkraneo)

---

> [!NOTE]
> This SDK was extracted from the **Preflight** project as a standalone library to serve as a reference implementation for the ACP community.
