# Disable flaky Python package tests
_final: prev: {
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
}
