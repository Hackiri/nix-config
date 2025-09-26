#!/usr/bin/env bash

# Enhanced Nix Development Configuration Test Script
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

echo -e "${BLUE}🧪 Testing Enhanced Nix Development Configuration${NC}"
echo "=================================================="

# Test 1: Custom Development Tools
log_info "Testing custom development tools..."
if command -v dev-tools >/dev/null 2>&1; then
    log_success "dev-tools is installed"
    echo "  Version info:"
    dev-tools help | head -5
else
    log_error "dev-tools not found"
fi

if command -v devshell >/dev/null 2>&1; then
    log_success "devshell is installed"
else
    log_error "devshell not found"
fi

echo ""

# Test 2: Core Kubernetes Tools
log_info "Testing core Kubernetes tools..."
for tool in kubectl helm kustomize; do
    if command -v $tool >/dev/null 2>&1; then
        log_success "$tool is available"
    else
        log_warning "$tool not found"
    fi
done

echo ""

# Test 3: Context Management Tools
log_info "Testing Kubernetes context management..."
for tool in kubectx kubecolor; do
    if command -v $tool >/dev/null 2>&1; then
        log_success "$tool is available"
    else
        log_warning "$tool not found"
    fi
done

echo ""

# Test 4: Observability Tools
log_info "Testing observability tools..."
for tool in k9s stern popeye; do
    if command -v $tool >/dev/null 2>&1; then
        log_success "$tool is available"
    else
        log_warning "$tool not found"
    fi
done

echo ""

# Test 5: Security Tools
log_info "Testing security tools..."
for tool in kube-bench; do
    if command -v $tool >/dev/null 2>&1; then
        log_success "$tool is available"
    else
        log_warning "$tool not found"
    fi
done

echo ""

# Test 6: GitOps Tools
log_info "Testing GitOps tools..."
for tool in argocd flux skaffold; do
    if command -v $tool >/dev/null 2>&1; then
        log_success "$tool is available"
    else
        log_warning "$tool not found"
    fi
done

echo ""

# Test 7: Container Tools
log_info "Testing container registry tools..."
for tool in skopeo dive crane; do
    if command -v $tool >/dev/null 2>&1; then
        log_success "$tool is available"
    else
        log_warning "$tool not found"
    fi
done

echo ""

# Test 8: Infrastructure as Code
log_info "Testing Infrastructure as Code tools..."
for tool in terraform ansible; do
    if command -v $tool >/dev/null 2>&1; then
        log_success "$tool is available"
    else
        log_warning "$tool not found"
    fi
done

echo ""

# Test 9: Cloud CLIs
log_info "Testing cloud provider CLIs..."
if command -v aws >/dev/null 2>&1; then
    log_success "AWS CLI is available"
else
    log_warning "AWS CLI not found"
fi

if command -v gcloud >/dev/null 2>&1; then
    log_success "Google Cloud SDK is available"
else
    log_warning "Google Cloud SDK not found"
fi

if command -v az >/dev/null 2>&1; then
    log_success "Azure CLI is available"
else
    log_warning "Azure CLI not found"
fi

echo ""

# Test 10: Enhanced direnv
log_info "Testing enhanced direnv..."
if command -v direnv >/dev/null 2>&1; then
    log_success "direnv is available"
    direnv --version
else
    log_error "direnv not found"
fi

echo ""

# Test 11: Development utilities
log_info "Testing development utilities..."
for tool in jq yq curl httpie; do
    if command -v $tool >/dev/null 2>&1; then
        log_success "$tool is available"
    else
        log_warning "$tool not found"
    fi
done

echo ""

# Summary
echo -e "${BLUE}📊 Test Summary${NC}"
echo "==============="
log_info "Your enhanced Nix development configuration has been tested!"
log_info "Any warnings above indicate optional tools that may not be available on macOS"
log_success "Core functionality should be working properly"

echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "1. Try 'dev-tools info' in a project directory"
echo "2. Test 'kubectl version --client' for Kubernetes tools"
echo "3. Create a test project with direnv to test enhanced layouts"
echo "4. Use 'k9s' to connect to a Kubernetes cluster"
