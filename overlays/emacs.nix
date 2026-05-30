# Emacs overlay configuration
# Note: emacs-gtk3 is marked broken in nixpkgs 26.05; use pgtk on Linux instead.
_: _final: prev: {
  # Main Emacs build - native compilation + tree-sitter
  # macOS: native Cocoa GUI; Linux: pure GTK (Wayland-native, replaces broken GTK3)
  emacs-git = prev.emacs.override {
    withNativeCompilation = true;
    withTreeSitter = true;
    withNS = prev.stdenv.isDarwin;
    withPgtk = prev.stdenv.isLinux;
  };
}
