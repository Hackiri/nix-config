#!/usr/bin/env zsh
# Test script for FZF integrations in zsh config
# This script tests all the fzf keybindings and helper functions

echo "=================================="
echo "FZF Configuration Test Suite"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

success_count=0
fail_count=0
skip_count=0

# Helper function to print test results
print_result() {
  local test_name="$1"
  local status="$2"
  local message="$3"

  case "$status" in
    "PASS")
      echo -e "${GREEN}✓${NC} ${test_name}: ${message}"
      ((success_count++))
      ;;
    "FAIL")
      echo -e "${RED}✗${NC} ${test_name}: ${message}"
      ((fail_count++))
      ;;
    "SKIP")
      echo -e "${YELLOW}⊘${NC} ${test_name}: ${message}"
      ((skip_count++))
      ;;
  esac
}

echo -e "${BLUE}=== Core FZF Configuration ===${NC}"
echo ""

# Test 1: Check if FZF is installed
if command -v fzf > /dev/null 2>&1; then
  fzf_version=$(fzf --version | awk '{print $1}')
  print_result "FZF Installation" "PASS" "Found version $fzf_version"
else
  print_result "FZF Installation" "FAIL" "fzf not found in PATH"
fi

# Test 2: Check FZF environment variables
if [ -n "$FZF_DEFAULT_COMMAND" ]; then
  print_result "FZF_DEFAULT_COMMAND" "PASS" "$FZF_DEFAULT_COMMAND"
else
  print_result "FZF_DEFAULT_COMMAND" "FAIL" "Not set"
fi

if [ -n "$FZF_DEFAULT_OPTS" ]; then
  print_result "FZF_DEFAULT_OPTS" "PASS" "$FZF_DEFAULT_OPTS"
else
  print_result "FZF_DEFAULT_OPTS" "FAIL" "Not set"
fi

# Test 3: Check fd command (used by FZF)
if command -v fd > /dev/null 2>&1; then
  fd_version=$(fd --version | awk '{print $2}')
  print_result "fd Installation" "PASS" "Found version $fd_version"
else
  print_result "fd Installation" "FAIL" "fd not found (required for FZF_DEFAULT_COMMAND)"
fi

# Test 4: Check bat command (used for previews)
if command -v bat > /dev/null 2>&1; then
  bat_version=$(bat --version | awk '{print $2}')
  print_result "bat Installation" "PASS" "Found version $bat_version"
else
  print_result "bat Installation" "FAIL" "bat not found (required for previews)"
fi

# Test 5: Check eza command (used for directory previews)
if command -v eza > /dev/null 2>&1; then
  eza_version=$(eza --version | head -1 | awk '{print $2}')
  print_result "eza Installation" "PASS" "Found version $eza_version"
else
  print_result "eza Installation" "FAIL" "eza not found (required for directory previews)"
fi

echo ""
echo -e "${BLUE}=== Git FZF Integration (Ctrl+G Ctrl+[key]) ===${NC}"
echo ""

# Test if we're in a git repo
if git rev-parse HEAD > /dev/null 2>&1; then
  print_result "Git Repository" "PASS" "Currently in a git repository"

  # Test helper function availability
  if type is_in_git_repo > /dev/null 2>&1; then
    print_result "is_in_git_repo function" "PASS" "Function is defined"
  else
    print_result "is_in_git_repo function" "FAIL" "Function not found"
  fi

  if type fzf-down > /dev/null 2>&1; then
    print_result "fzf-down function" "PASS" "Function is defined"
  else
    print_result "fzf-down function" "FAIL" "Function not found"
  fi

  # Test individual git helper functions
  for func in _gf _gb _gt _gh _gr _gs _gst _ga _gc; do
    if type "$func" > /dev/null 2>&1; then
      print_result "Git function $func" "PASS" "Defined"
    else
      print_result "Git function $func" "FAIL" "Not defined"
    fi
  done

  # Test ZLE widgets
  for widget in fzf-gf-widget fzf-gb-widget fzf-gt-widget fzf-gh-widget fzf-gr-widget fzf-gs-widget fzf-gst-widget fzf-ga-widget fzf-gc-widget; do
    if zle -l | grep -q "$widget"; then
      print_result "ZLE widget $widget" "PASS" "Registered"
    else
      print_result "ZLE widget $widget" "FAIL" "Not registered"
    fi
  done

else
  print_result "Git Repository" "SKIP" "Not in a git repository (git tests skipped)"
fi

echo ""
echo -e "${BLUE}=== Kubectl FZF Integration (Ctrl+K Ctrl+[key]) ===${NC}"
echo ""

# Test if kubectl is available
if command -v kubectl > /dev/null 2>&1; then
  kubectl_version=$(kubectl version --client --short 2>/dev/null | head -1)
  print_result "kubectl Installation" "PASS" "$kubectl_version"

  # Test helper function availability
  if type is_kubectl_available > /dev/null 2>&1; then
    print_result "is_kubectl_available function" "PASS" "Function is defined"
  else
    print_result "is_kubectl_available function" "FAIL" "Function not found"
  fi

  if type fzf-kube > /dev/null 2>&1; then
    print_result "fzf-kube function" "PASS" "Function is defined"
  else
    print_result "fzf-kube function" "FAIL" "Function not found"
  fi

  # Test individual kubectl helper functions
  for func in _kp _kn _kc _kl _ke _ks _kd _kx _kf; do
    if type "$func" > /dev/null 2>&1; then
      print_result "Kubectl function $func" "PASS" "Defined"
    else
      print_result "Kubectl function $func" "FAIL" "Not defined"
    fi
  done

  # Test ZLE widgets
  for widget in fzf-kp-widget fzf-kn-widget fzf-kc-widget fzf-kl-widget fzf-ke-widget fzf-ks-widget fzf-kd-widget fzf-kx-widget fzf-kf-widget; do
    if zle -l | grep -q "$widget"; then
      print_result "ZLE widget $widget" "PASS" "Registered"
    else
      print_result "ZLE widget $widget" "FAIL" "Not registered"
    fi
  done

else
  print_result "kubectl Installation" "SKIP" "kubectl not found (kubectl tests skipped)"
fi

echo ""
echo -e "${BLUE}=== Talos FZF Integration (Ctrl+T Ctrl+[key]) ===${NC}"
echo ""

# Test if talosctl is available
if command -v talosctl > /dev/null 2>&1; then
  talos_version=$(talosctl version --client --short 2>/dev/null)
  print_result "talosctl Installation" "PASS" "$talos_version"

  # Test helper function availability
  if type is_talosctl_available > /dev/null 2>&1; then
    print_result "is_talosctl_available function" "PASS" "Function is defined"
  else
    print_result "is_talosctl_available function" "FAIL" "Function not found"
  fi

  if type fzf-talos > /dev/null 2>&1; then
    print_result "fzf-talos function" "PASS" "Function is defined"
  else
    print_result "fzf-talos function" "FAIL" "Function not found"
  fi

  # Test individual talos helper functions
  for func in _tn _td _tl _tm _tc _tx _tu _th; do
    if type "$func" > /dev/null 2>&1; then
      print_result "Talos function $func" "PASS" "Defined"
    else
      print_result "Talos function $func" "FAIL" "Not defined"
    fi
  done

  # Test ZLE widgets
  for widget in fzf-tn-widget fzf-td-widget fzf-tl-widget fzf-tm-widget fzf-tc-widget fzf-tx-widget fzf-tu-widget fzf-th-widget; do
    if zle -l | grep -q "$widget"; then
      print_result "ZLE widget $widget" "PASS" "Registered"
    else
      print_result "ZLE widget $widget" "FAIL" "Not registered"
    fi
  done

else
  print_result "talosctl Installation" "SKIP" "talosctl not found (talos tests skipped)"
fi

echo ""
echo -e "${BLUE}=== Cilium FZF Integration (Ctrl+C Ctrl+[key]) ===${NC}"
echo ""

# Test if cilium is available
if command -v cilium > /dev/null 2>&1; then
  cilium_version=$(cilium version --client 2>/dev/null | grep "cilium-cli" | awk '{print $2}')
  print_result "cilium Installation" "PASS" "Found version $cilium_version"

  # Test helper function availability
  if type is_cilium_available > /dev/null 2>&1; then
    print_result "is_cilium_available function" "PASS" "Function is defined"
  else
    print_result "is_cilium_available function" "FAIL" "Function not found"
  fi

  if type fzf-cilium > /dev/null 2>&1; then
    print_result "fzf-cilium function" "PASS" "Function is defined"
  else
    print_result "fzf-cilium function" "FAIL" "Function not found"
  fi

  # Test individual cilium helper functions
  for func in _cp _cs _ct _ce _cm _cl _cv _cb _cu _co _ch _cd; do
    if type "$func" > /dev/null 2>&1; then
      print_result "Cilium function $func" "PASS" "Defined"
    else
      print_result "Cilium function $func" "FAIL" "Not defined"
    fi
  done

  # Test ZLE widgets
  for widget in fzf-cp-widget fzf-cs-widget fzf-ct-widget fzf-ce-widget fzf-cm-widget fzf-cl-widget fzf-cv-widget fzf-cb-widget fzf-cu-widget fzf-co-widget fzf-ch-widget fzf-cd-widget; do
    if zle -l | grep -q "$widget"; then
      print_result "ZLE widget $widget" "PASS" "Registered"
    else
      print_result "ZLE widget $widget" "FAIL" "Not registered"
    fi
  done

else
  print_result "cilium Installation" "SKIP" "cilium not found (cilium tests skipped)"
fi

echo ""
echo -e "${BLUE}=== Additional FZF Functions ===${NC}"
echo ""

# Test join-lines helper function
if type join-lines > /dev/null 2>&1; then
  print_result "join-lines function" "PASS" "Function is defined"
else
  print_result "join-lines function" "FAIL" "Function not found"
fi

# Test completion functions
if type _fzf_compgen_path > /dev/null 2>&1; then
  print_result "_fzf_compgen_path function" "PASS" "Function is defined"
else
  print_result "_fzf_compgen_path function" "FAIL" "Function not found"
fi

if type _fzf_compgen_dir > /dev/null 2>&1; then
  print_result "_fzf_compgen_dir function" "PASS" "Function is defined"
else
  print_result "_fzf_compgen_dir function" "FAIL" "Function not found"
fi

if type _fzf_comprun > /dev/null 2>&1; then
  print_result "_fzf_comprun function" "PASS" "Function is defined"
else
  print_result "_fzf_comprun function" "FAIL" "Function not found"
fi

echo ""
echo "=================================="
echo -e "${BLUE}Test Summary${NC}"
echo "=================================="
echo -e "${GREEN}Passed:${NC} $success_count"
echo -e "${RED}Failed:${NC} $fail_count"
echo -e "${YELLOW}Skipped:${NC} $skip_count"
echo ""

if [ $fail_count -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed. Please check your configuration.${NC}"
  exit 1
fi
