{
  pkgs,
  hostName ? "mbp",
  ...
}: let
  aliases =
    (
      if pkgs.stdenv.isDarwin
      then {
        # Darwin rebuild commands
        nixb = "sudo darwin-rebuild"; # Base command
        # Darwin-specific network aliases
        ports = "sudo lsof -iTCP -sTCP:LISTEN -n -P";
        conns = "netstat -an | grep ESTABLISHED";
        nixbuild = "sudo darwin-rebuild build --flake ~/nix-config\\#${hostName}"; # Build only
        nixswitch = "sudo darwin-rebuild switch --flake ~/nix-config\\#${hostName}"; # Build and activate
        nixcheck = "sudo darwin-rebuild check --flake ~/nix-config\\#${hostName}"; # Check configuration
        nixdry = "sudo darwin-rebuild dry-build --flake ~/nix-config\\#${hostName}"; # Test build without making changes
        nixedit = "sudo darwin-rebuild edit --flake ~/nix-config\\#${hostName}"; # Open configuration in $EDITOR
        nixlist = "sudo darwin-rebuild --list-generations"; # List all generations
        nixrollback = "sudo darwin-rebuild switch --rollback"; # Rollback to previous generation
        nixtrace = "sudo darwin-rebuild switch --flake ~/nix-config\\#${hostName} --show-trace"; # Show trace for debugging
        nixverbose = "sudo darwin-rebuild switch --flake ~/nix-config\\#${hostName} --verbose"; # Verbose output
      }
      else {
        # NixOS rebuild commands
        nixb = "sudo nixos-rebuild"; # Base command
        nixbuild = "sudo nixos-rebuild build --flake ~/nix-config\\#${hostName}"; # Build only
        nixswitch = "sudo nixos-rebuild switch --flake ~/nix-config\\#${hostName}"; # Build and activate
        nixcheck = "sudo nixos-rebuild dry-build --flake ~/nix-config\\#${hostName}"; # Check configuration
        nixdry = "sudo nixos-rebuild dry-build --flake ~/nix-config\\#${hostName}"; # Test build without making changes
        nixedit = "sudo nixos-rebuild edit --flake ~/nix-config\\#${hostName}"; # Open configuration in $EDITOR
        nixlist = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system"; # List all generations
        nixrollback = "sudo nixos-rebuild switch --rollback"; # Rollback to previous generation
        nixtrace = "sudo nixos-rebuild switch --flake ~/nix-config\\#${hostName} --show-trace"; # Show trace for debugging
        nixverbose = "sudo nixos-rebuild switch --flake ~/nix-config\\#${hostName} --verbose"; # Verbose output
      }
    )
    // {
      nixclean = "sudo nix-collect-garbage -d"; # Clean old generations

      # Nix utilities
      nxsearch = "nix search nixpkgs"; # Search packages
      nxrepl = "nix repl --expr 'import <nixpkgs> {}'"; # Interactive nix REPL
      nxdev = "nix develop .#"; # Enter dev shell

      # Kubernetes aliases
      k = "kubectl";
      kns = "kubectl config set-context --current --namespace";
      kg = "kubectl get";
      kd = "kubectl describe";
      kl = "kubectl logs";
      ke = "kubectl edit";
      kx = "kubectl exec -it";
      ka = "kubectl apply -f";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";
      kgd = "kubectl get deployments";
      kgn = "kubectl get nodes";
      kgc = "kubectl get configmaps";
      kgsec = "kubectl get secrets";
      kgaa = "kubectl get all -A";
      kgpsn = "kubectl get pods --namespace";
      kdaa = "kubectl delete all --all -n";
      krestartpo = "kubectl rollout restart deployment";

      # Helm aliases
      h = "helm";
      hi = "helm install";
      hu = "helm upgrade";
      hl = "helm list";
      hd = "helm delete";
      hr = "helm repo";
      hru = "helm repo update";
      hs = "helm search";

      # Podman
      pps = "podman ps --format 'table {{ .Names }}\t{{ .Status }}' --sort names";
      pclean = "podman ps -a | grep -v 'CONTAINER\|_config\|_data\|_run' | cut -c-12 | xargs podman rm 2>/dev/null";
      piclean = "podman images | grep '<none>' | grep -P '[1234567890abcdef]{12}' -o | xargs -L1 podman rmi 2>/dev/null";
      pi = "podman images";
      pcomp = "podman-compose";
      prestart = "podman-compose down && podman-compose up -d";

      # Docker aliases for Podman (moved from system configuration)
      docker = "podman";
      "docker-compose" = "podman-compose";

      # Terraform alias for OpenTofu (open-source fork)
      terraform = "tofu";
      tf = "tofu";

      # Get resource information
      kgps = "kubectl get pods --sort-by=.metadata.name";
      kgsvc = "kubectl get svc --sort-by=.metadata.name";
      kgns = "kubectl get namespaces";
      kgpojson = "kubectl get pods -o json";
      kgnodes = "kubectl get nodes -o wide";

      # Create, apply, and edit resources (ka and ke defined above)
      kset = "kubectl set";

      # Delete resources
      kdel = "kubectl delete";
      kdelall = "kubectl delete all --all";

      # Logs and events (kl defined above)
      kevents = "kubectl get events --sort-by=.metadata.creationTimestamp";

      # Exec into containers and debugging (kx and kd defined above)
      kshell = "kubectl exec -it -- /bin/sh";

      # Manage contexts and namespaces (kns defined above)
      kusectx = "kubectl config use-context";
      kgctx = "kubectl config get-contexts";

      # Deployment management
      kroll = "kubectl rollout restart";
      kstatus = "kubectl rollout status";
      kscale = "kubectl scale --replicas";

      # Port forwarding
      kfwd = "kubectl port-forward";

      # Useful lists and all-resources views
      kall = "kubectl get all --all-namespaces";
      kga = "kubectl get all";
      ksvcns = "kubectl get svc -n";

      # Pod troubleshooting
      ktop = "kubectl top pods";
      ktopnodes = "kubectl top nodes";
      kdebug = "kubectl run debug --rm -it --restart=Never --image=busybox -- /bin/sh";

      # Miscellaneous shortcuts
      kapplyd = "kubectl apply -k .";
      kapprove = "kubectl certificate approve";

      # Git-related commands
      gaa = "git add .";
      gcmsg = "git commit -m";
      gst = "git status .";
      gco = "git checkout";
      gcb = "git checkout -b";
      gcm = "git checkout main";
      gl = "git log --oneline --graph";
      gpull = "git pull --rebase";
      gpush = "git push";
      glast = "git log -1 HEAD";

      # Git diff with delta (uses delta via gitconfig)
      gd = "git diff";
      gds = "git diff --staged";
      gdw = "git diff --word-diff";
      gdn = "git diff --name-only";

      # System and utility commands (macOS uses launchctl, not systemctl)
      edit = "emacsclient -n -c";
      ednix = "emacsclient -nw ~/nix-config/flake.nix";
      ec = "emacsclient -nw";
      ecx = "emacsclient -n -c";
      eterm = "emacsclient -nw -e '(vterm)'";
      sgrep = "rg -M 200 --hidden";

      # FZF combinations
      vif = "nvim $(fzf -m --preview=\"bat --color=always {}\")";
      fcd = "cd $(fd --type d | fzf --preview='eza --tree --level=1 --color=always {}')";
      fh = "history 0 | fzf --tac --tiebreak=index";
      fkill = "ps aux | fzf --multi | awk '{print $2}' | xargs kill -9";
      fenv = "env | fzf";
      frg = "rg --color=always --line-number --no-heading --smart-case \"\" | fzf --ansi --preview=\"bat --color=always {1} --highlight-line {2}\"";
      # eza aliases (defined directly to avoid flag conflicts from chaining)
      lse = "eza --icons -l -T -L=1";
      l = "eza --icons -l";
      ll = "eza --icons -la";
      lsa = "eza --icons -la";
      lstree = "eza --icons -T";
      hist = "history | grep";

      # Modern tool aliases
      cdiff = "colordiff";
      prs = "procs";
      lg = "lazygit";
      md = "glow";

      # Claude Code workflow aliases
      loc = "tokei";
      codestats = "tokei --sort code";
      bench = "hyperfine";
      benchw = "hyperfine --warmup 3";
      we = "watchexec";
      wer = "watchexec --restart";
      wec = "watchexec --clear";

      # Enhanced ripgrep
      rgf = "rg --files | rg";
      rgi = "rg -i";
      rgl = "rg -l";

      # Networking and system monitoring
      psg = "ps aux | grep";
      myip = "curl ifconfig.me";
      pingg = "ping google.com";
      topd = "du -sh * | sort -h";

      # File and process management
      mkd = "mkdir -p";
      vi = "nvim";
      files = "yazi";
      untar = "tar -xvf";
      fin = "fzf --bind 'enter:become(nvim {})'";

      # AI tools
      mcpl = "mcpl --config ~/.config/mcpl/mcp.json";

      # nix-darwin directory shortcuts
      dots = "cd ~/nix-config";

      # Pre-commit
      pcmit = "pre-commit run --all-files";

      # Tmux aliases
      ta = "tmux attach -t";
      tad = "tmux attach -d -t";
      ts = "tmux new-session -s";
      tl = "tmux list-sessions";
      tksv = "tmux kill-server";
      tkss = "tmux kill-session -t";

      # Better directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
    };
in {
  programs = {
    zsh.shellAliases = aliases;
    bash.shellAliases = aliases;

    zsh.initContent = ''
      # Suffix aliases — open files by typing the filename
      alias -s py=python3
      alias -s js=node
      alias -s md=glow
      alias -s json="jq ."
      alias -s {yml,yaml}=''${EDITOR:-nvim}
      alias -s nix=''${EDITOR:-nvim}
      alias -s txt=''${EDITOR:-nvim}
      alias -s git='git clone'

      # Global aliases — substituted anywhere on the line
      alias -g G='| grep'
      alias -g L='| less'
      alias -g H='| head -20'
      alias -g T='| tail -20'
      alias -g J='| jq .'
      alias -g C='| wc -l'
      alias -g NUL='> /dev/null 2>&1'

      # Extract function (replaces oh-my-zsh extract plugin)
      extract() {
        if [[ ! -f "$1" ]]; then
          echo "extract: '$1' is not a valid file" >&2
          return 1
        fi
        case "$1" in
          *.tar.bz2)  tar xjf "$1"     ;;
          *.tar.gz)   tar xzf "$1"     ;;
          *.tar.xz)   tar xJf "$1"     ;;
          *.bz2)      bunzip2 "$1"     ;;
          *.rar)      unrar x "$1"     ;;
          *.gz)       gunzip "$1"      ;;
          *.tar)      tar xf "$1"      ;;
          *.tbz2)     tar xjf "$1"     ;;
          *.tgz)      tar xzf "$1"     ;;
          *.zip)      unzip "$1"       ;;
          *.Z)        uncompress "$1"  ;;
          *.7z)       7z x "$1"        ;;
          *.xz)       xz -d "$1"       ;;
          *.zst)      zstd -d "$1"     ;;
          *)          echo "extract: unknown archive format '$1'" >&2; return 1 ;;
        esac
      }
    '';
  };
}
