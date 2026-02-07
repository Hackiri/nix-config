# Terminal applications and related tools
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.features.development.packages.terminals.enable {
    home.packages = with pkgs; [
      #--------------------------------------------------
      # Tmux Session Management
      #--------------------------------------------------
      tmuxinator # For managing complex tmux sessions

      #--------------------------------------------------
      # Terminal Dependencies (cross-platform)
      #--------------------------------------------------
      moreutils # For sponge command used in tmux-resurrect
      # Note: reattach-to-user-namespace moved to home/darwin.nix (macOS-specific)

      #--------------------------------------------------
      # Additional Terminal Tools (add as needed)
      #--------------------------------------------------
    ];
  };
}
