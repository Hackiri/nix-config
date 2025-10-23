# Emacs overlay configuration
# This overlay provides custom Emacs configurations and packages
final: prev: {
  # Emacs git/unstable version - main package used throughout config
  emacs-git = prev.emacs-unstable.override {
    # Enable native compilation for better performance
    withNativeCompilation = true;
    # Enable tree-sitter support
    withTreeSitter = true;
    # macOS specific optimizations
    withNS = prev.stdenv.isDarwin;
    # Linux specific features
    withGTK3 = prev.stdenv.isLinux;
    withXwidgets = prev.stdenv.isLinux;
  };
  # Custom Emacs configurations (alternative build)
  emacs-custom = prev.emacs-unstable.override {
    # Enable native compilation for better performance
    withNativeCompilation = true;
    # Enable tree-sitter support
    withTreeSitter = true;
    # Enable additional features
    withGTK3 = prev.stdenv.isLinux;
    withXwidgets = prev.stdenv.isLinux;
    # macOS specific optimizations
    withNS = prev.stdenv.isDarwin;
  };

  # Emacs with daemon support optimized
  emacs-daemon = prev.emacs-unstable.override {
    withNativeCompilation = true;
    withTreeSitter = true;
    withGTK3 = prev.stdenv.isLinux;
    withNS = prev.stdenv.isDarwin;
  };

  # Lightweight Emacs for quick editing
  emacs-light = prev.emacs.override {
    withNativeCompilation = false;
    withTreeSitter = false;
    withX = false;
    withGTK2 = false;
    withGTK3 = false;
  };

  # Custom Emacs packages set with additional packages
  emacsPackagesFor-custom = emacsPackages:
    emacsPackages.overrideScope (_efinal: eprev: {
      # Add any custom Emacs package overrides here
      # Example: treesit-grammars with additional languages
      treesit-grammars = eprev.treesit-grammars.with-grammars (grammars:
        with grammars; [
          tree-sitter-bash
          tree-sitter-c
          tree-sitter-cpp
          tree-sitter-css
          tree-sitter-dockerfile
          tree-sitter-go
          tree-sitter-html
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-lua
          tree-sitter-markdown
          tree-sitter-nix
          tree-sitter-python
          tree-sitter-rust
          tree-sitter-toml
          tree-sitter-tsx
          tree-sitter-typescript
          tree-sitter-yaml
        ]);
    });

  # Emacs with custom package set
  emacs-with-packages = (prev.emacsPackagesFor final.emacs-git).emacsWithPackages;
}
