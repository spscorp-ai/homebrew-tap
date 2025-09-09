# Homebrew Tap for Lab Agent Drone

This is the official Homebrew tap for Lab Agent Drone.

## Installation

```bash
brew tap spscorp-ai/tap
brew install lab-agent-drone
```

## Usage

```bash
export LAB_API_KEY="your_token_here"
lab-agent-drone
```

## What is Lab Agent Drone?

Lab Agent Drone is a fault-tolerant command execution daemon that connects to lab-backend to receive and execute coding agent commands. It serves as a reliable executor for agentic coding operations with:

- Redis polling with automatic HTTP fallback
- Real-time system information updates  
- Command deduplication and caching
- Comprehensive fault tolerance
- Cross-platform support (Linux, macOS, Docker)

## Documentation

- [GitHub Repository](https://github.com/spscorp-ai/lab-rpc-agent-cli)
- [Command Reference](https://github.com/spscorp-ai/lab-rpc-agent-cli/blob/main/COMMAND_API_REFERENCE.md)
- [Installation Guide](https://github.com/spscorp-ai/lab-rpc-agent-cli/blob/main/README.md)
