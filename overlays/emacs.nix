# Emacs overlay configuration
# This overlay provides custom Emacs configurations and packages
# Note: emacs-gtk3 is marked broken in nixpkgs 25.11; use pgtk on Linux instead.
final: prev: {
  # Emacs stable version - main package used throughout config
  emacs-git = prev.emacs.override {
    withNativeCompilation = true;
    withTreeSitter = true;
    # macOS: native Cocoa GUI; Linux: pure GTK (Wayland-native, replaces broken GTK3)
    withNS = prev.stdenv.isDarwin;
    withPgtk = prev.stdenv.isLinux;
  };
  # Custom Emacs configurations (alternative build)
  emacs-custom = prev.emacs.override {
    withNativeCompilation = true;
    withTreeSitter = true;
    withPgtk = prev.stdenv.isLinux;
    withNS = prev.stdenv.isDarwin;
  };

  # Emacs with daemon support optimized
  emacs-daemon = prev.emacs.override {
    withNativeCompilation = true;
    withTreeSitter = true;
    withPgtk = prev.stdenv.isLinux;
    withNS = prev.stdenv.isDarwin;
  };

  # Lightweight Emacs for quick editing (no GUI toolkit)
  emacs-light = prev.emacs.override {
    withNativeCompilation = false;
    withTreeSitter = false;
    withPgtk = false;
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
