{
  # Darwin rebuild commands
  nixb = "sudo darwin-rebuild"; # Base command

  # Build variants
  nixbuild = "sudo darwin-rebuild build --flake ~/nix-config#mbp"; # Build only
  nixswitch = "sudo darwin-rebuild switch --flake ~/nix-config#mbp"; # Build and activate
  nixcheck = "sudo darwin-rebuild check --flake ~/nix-config#mbp"; # Check configuration
  nixdry = "sudo darwin-rebuild dry-build --flake ~/nix-config#mbp"; # Test build without making changes
  nixedit = "sudo darwin-rebuild edit --flake ~/nix-config#mbp"; # Open configuration in $EDITOR

  # System management
  nixlist = "sudo darwin-rebuild --list-generations"; # List all generations
  nixrollback = "sudo darwin-rebuild switch --rollback"; # Rollback to previous generation
  nixclean = "sudo nix-collect-garbage -d"; # Clean old generations

  # Debugging options
  nixtrace = "sudo darwin-rebuild switch --flake ~/nix-config#mbp --show-trace"; # Show trace for debugging
  nixverbose = "sudo darwin-rebuild switch --flake ~/nix-config#mbp --verbose"; # Verbose output

  # Nix utilities
  nxsearch = "nix search nixpkgs"; # Search packages
  nxrepl = "nix repl '<nixpkgs>'"; # Interactive nix REPL
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
  ksysgpoyamll = "kubectl --namespace=kube-system get pods -o=yaml -l";
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

  # Create, apply, and edit resources
  kapp = "kubectl apply -f";
  kedit = "kubectl edit";
  kset = "kubectl set";

  # Delete resources
  kdel = "kubectl delete";
  kdelall = "kubectl delete all --all";

  # Logs and events
  klogs = "kubectl logs";
  kevents = "kubectl get events --sort-by=.metadata.creationTimestamp";

  # Exec into containers and debugging
  kexec = "kubectl exec -it";
  kdescribe = "kubectl describe";
  kshell = "kubectl exec -it -- /bin/sh";

  # Manage contexts and namespaces
  kusectx = "kubectl config use-context";
  kgctx = "kubectl config get-contexts";
  knschange = "kubectl config set-context --current --namespace";

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

  # System and utility commands (macOS uses launchctl, not systemctl)
  edit = "emacsclient -n -c";
  ednix = "emacsclient -nw ~/nix-config/flake.nix";
  ec = "emacsclient -nw";
  ecx = "emacsclient -n -c";
  eterm = "emacsclient -nw -e '(vterm)'";
  sgrep = "rg -M 200 --hidden";

  # pnpm commands
  task-master = "pnpm task-master";

  # FZF combinations
  vif = "nvim $(fzf -m --preview=\"bat --color=always {}\")";
  fcd = "cd $(find . -type d | fzf --preview='eza --tree --level=1 --color=always {}')";
  fh = "history 0 | fzf --tac --tiebreak=index";
  fkill = "ps aux | fzf --multi | awk '{print $2}' | xargs kill -9";
  fenv = "env | fzf";
  frg = "rg --color=always --line-number --no-heading --smart-case \"\" | fzf --ansi --preview=\"bat --color=always {1} --highlight-line {2}\"";
  cat = "bat";
  ls = "eza --icons -l -T -L=1";
  l = "ls -l";
  ll = "ls -alh";
  lsa = "ls -a";
  lstree = "ls -R | tree";
  clr = "clear";
  hist = "history | grep";
  diff = "colordiff";
  find = "fd";
  grep = "rg";
  ps = "procs";
  top = "btm";
  du = "dust";
  df = "duf";
  lg = "lazygit";
  j = "zoxide";
  md = "glow";

  # Networking and system monitoring
  psg = "ps aux | grep";
  netstat = "sudo netstat -tulnp";
  ss = "sudo ss -tulw";
  ipinfo = "ip addr show";
  myip = "curl ifconfig.me";
  pingg = "ping google.com";
  topd = "du -sh * | sort -h";

  # File and process management
  mkd = "mkdir -p";
  vi = "nvim";
  files = "yazi";
  untar = "tar -xvf";
  fin = "fzf --bind 'enter:become(nvim {})'";

  # Alias management
  aliasadd = "echo 'alias $1=\"$2\"' >> ~/.bash_aliases && source ~/.bash_aliases";
  aliaslist = "cat ~/.bash_aliases | grep alias";

  # AI tools
  ai = "aichat";

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
}
