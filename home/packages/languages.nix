# Programming languages and runtimes
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Node.js ecosystem
    nodejs # JavaScript runtime environment
    yarn # Fast, reliable, and secure dependency management
    pnpm # Fast, disk space efficient package manager
    bun # Fast, disk space efficient package manager

    # Python ecosystem (core tools)
    uv # Fast Python package installer and resolver

    # PHP
    php84Packages.composer # Dependency manager for PHP
  ];
}
