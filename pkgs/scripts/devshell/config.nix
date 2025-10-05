# Configuration for the development shell environment
{
  programs.devshell = {
    enable = true;
    # Enable specific language environments as needed
    features = {
      python = true;
      rust = true;
      go = true;
      node = true;
    };
  };
}
