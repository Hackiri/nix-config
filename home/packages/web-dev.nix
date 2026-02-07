# Web development tools and utilities
# Note: curl, wget are in network.nix (imported by minimal.nix)
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.features.development.packages.webDev.enable {
    home.packages = with pkgs; [
      #--------------------------------------------------
      # API Testing and Development
      #--------------------------------------------------
      httpie # Human-friendly HTTP client
      grpcurl # gRPC client for command-line

      #--------------------------------------------------
      # Load Testing and Benchmarking
      #--------------------------------------------------
      wrk # Modern HTTP benchmarking tool

      #--------------------------------------------------
      # Web Servers (uncomment as needed)
      #--------------------------------------------------
      # caddy # Modern, automatic HTTPS web server
      # nodePackages.http-server # Simple HTTP server
      # nodePackages.live-server # Live-reloading HTTP server

      #--------------------------------------------------
      # Tunneling and Exposure (uncomment as needed)
      #--------------------------------------------------
      # ngrok # Secure tunnels to localhost (requires manual install)
      # cloudflared # Cloudflare Tunnel client
    ];
  };
}
