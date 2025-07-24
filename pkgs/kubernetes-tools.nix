{pkgs ? import <nixpkgs> {}}:
# This package set contains Kubernetes and related infrastructure tools
with pkgs; [
  #--------------------------------------------------
  # Kubernetes Core Tools
  #--------------------------------------------------
  kubectl # Kubernetes command-line tool
  kubernetes-helm # Kubernetes package manager

  #--------------------------------------------------
  # Context & Namespace Management
  #--------------------------------------------------
  kubectx # Fast context switching between clusters (includes kubens)

  #--------------------------------------------------
  # Log Management & Debugging
  #--------------------------------------------------
  stern # Multi-pod log tailing with color coding

  #--------------------------------------------------
  # Kubernetes Management UIs
  #--------------------------------------------------
  k9s # Terminal-based Kubernetes dashboard

  #--------------------------------------------------
  # Security & Compliance
  #--------------------------------------------------
  kube-bench # CIS Kubernetes benchmark security scanner

  #--------------------------------------------------
  # GitOps & CI/CD
  #--------------------------------------------------
  argocd # GitOps continuous delivery CLI
  flux # GitOps toolkit CLI
  skaffold # Local development workflow automation

  #--------------------------------------------------
  # Service Mesh
  #--------------------------------------------------
  istioctl # Istio service mesh management

  #--------------------------------------------------
  # Local Development
  #--------------------------------------------------
  kind # Kubernetes in Docker
  minikube # Local Kubernetes clusters

  #--------------------------------------------------
  # Kubernetes Networking
  #--------------------------------------------------
  cilium-cli # CLI for Cilium CNI

  #--------------------------------------------------
  # Kubernetes Configuration Management
  #--------------------------------------------------
  kustomize # Kubernetes native configuration management

  #--------------------------------------------------
  # Kubernetes Extensions
  #--------------------------------------------------
  krew # kubectl plugin manager

  #--------------------------------------------------
  # Kubernetes Distribution Tools
  #--------------------------------------------------
  talosctl # CLI for Talos Linux management

  #--------------------------------------------------
  # Infrastructure as Code
  #--------------------------------------------------
  terraform # Infrastructure as code tool

  #--------------------------------------------------
  # Helm Plugins
  #--------------------------------------------------
  kubernetes-helmPlugins.helm-diff # Show diff between releases for helm
]
