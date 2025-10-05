# Kubernetes Tools Module

This module provides comprehensive Kubernetes development and operations tools.

## Usage

Enable in your configuration:

```nix
programs.kube.enable = true;
programs.kube.toolset = "admin";  # or "minimal", "devops", "operations", "complete"
```

## Toolsets

- **minimal**: Core tools only (kubectl, helm, kustomize, kubectx, kubecolor)
- **admin**: For cluster administration (core + observability + security)
- **operations**: For production cluster management
- **devops**: For CI/CD and GitOps workflows
- **security-focused**: For cluster security auditing
- **mesh**: For service mesh management
- **complete**: All available tools

## Features

- K9s configuration with custom skin
- Shell completions for zsh and bash
- Kubecolor integration for colorized kubectl output
- Krew plugin manager support
