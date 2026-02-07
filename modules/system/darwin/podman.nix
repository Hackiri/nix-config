# Darwin Podman Docker compatibility
# Creates symlinks for Docker CLI compatibility
_: {
  system.activationScripts = {
    podmanDockerCompat.text = ''
      echo "Setting up Podman Docker compatibility symlinks..." >&2
      mkdir -p $HOME/.local/bin
      ln -sf $(which podman) $HOME/.local/bin/docker 2>/dev/null || true
      ln -sf $(which podman-compose) $HOME/.local/bin/docker-compose 2>/dev/null || true
      mkdir -p $HOME/.docker
    '';
  };
}
