# Darwin Podman Docker compatibility
# Creates symlinks for Docker CLI compatibility
{username, ...}: {
  system.activationScripts = {
    podmanDockerCompat.text = ''
      echo "Setting up Podman Docker compatibility symlinks..." >&2
      mkdir -p /Users/${username}/.local/bin
      ln -sf $(which podman) /Users/${username}/.local/bin/docker 2>/dev/null || true
      ln -sf $(which podman-compose) /Users/${username}/.local/bin/docker-compose 2>/dev/null || true
      mkdir -p /Users/${username}/.docker
    '';
  };
}
