# Web development tools and utilities
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Web Servers
    #--------------------------------------------------
    # caddy # Modern, automatic HTTPS web server
    # python3's http.server module available via Python runtime
    # nodePackages.http-server # Simple HTTP server (optional)
    # nodePackages.live-server # Live-reloading HTTP server (optional)

    #--------------------------------------------------
    # API Testing and Development
    #--------------------------------------------------
    httpie # Human-friendly HTTP client
    curl # Command-line HTTP client
    wget # Network downloader
    grpcurl # gRPC client for command-line

    #--------------------------------------------------
    # Load Testing and Benchmarking
    #--------------------------------------------------
    wrk # Modern HTTP benchmarking tool
    # apache-bench (ab) # Available via apacheHttpd package if needed

    #--------------------------------------------------
    # Tunneling and Exposure
    #--------------------------------------------------
    # ngrok # Secure tunnels to localhost (requires manual install)
    # cloudflared # Cloudflare Tunnel client (optional)
  ];
}
