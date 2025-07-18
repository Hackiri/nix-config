{pkgs ? import <nixpkgs> {}}:
# This package set contains Kubernetes and related infrastructure tools
with pkgs; [
  #--------------------------------------------------
  # Kubernetes Core Tools
  #--------------------------------------------------
  kubectl # Kubernetes command-line tool
  kubernetes-helm # Kubernetes package manager

  #--------------------------------------------------
  # Kubernetes Management UIs
  #--------------------------------------------------
  k9s # Terminal-based Kubernetes dashboard

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
