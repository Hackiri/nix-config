{lib, ...}: {
  options.features.development = {
    packages = {
      buildTools.enable = lib.mkEnableOption "build tools and compilers" // {default = true;};
      codeQuality.enable = lib.mkEnableOption "linters and formatters" // {default = true;};
      databases.enable = lib.mkEnableOption "database client tools" // {default = true;};
      languages.enable = lib.mkEnableOption "programming language runtimes" // {default = true;};
      security.enable = lib.mkEnableOption "security and encryption tools" // {default = true;};
      terminals.enable = lib.mkEnableOption "terminal applications" // {default = true;};
      webDev.enable = lib.mkEnableOption "web development tools" // {default = true;};
      custom.enable = lib.mkEnableOption "custom overlay packages" // {default = true;};
    };
  };
}
