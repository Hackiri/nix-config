# Disable flaky Python package tests
{inputs}: _final: prev: {
  pythonPackagesExtensions =
    (prev.pythonPackagesExtensions or [])
    ++ [
      (_: pySuper: {
        # Skip aiohttp tests - they hang indefinitely on macOS due to network-related tests
        aiohttp = pySuper.aiohttp.overridePythonAttrs (_: {
          doCheck = false;
        });
        # Skip azure-core tests - they hang indefinitely on macOS due to network-related tests
        azure-core = pySuper.azure-core.overridePythonAttrs (_: {
          doCheck = false;
        });
        # Skip twisted tests - they hang indefinitely on macOS due to network-related tests
        twisted = pySuper.twisted.overridePythonAttrs (_: {
          doCheck = false;
        });
      })
    ];

  # Use nixpkgs-unstable nerd-fonts.jetbrains-mono which doesn't depend on gftools/ffmpeg-python.
  # The stable (25.11) version builds jetbrains-mono via gftools which requires ffmpeg-python,
  # and ffmpeg-python tests are killed by SIGKILL in the Nix sandbox on macOS.
  nerd-fonts =
    prev.nerd-fonts
    // {
      inherit
        ((import inputs.nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        }).nerd-fonts)
        jetbrains-mono
        ;
    };
}
