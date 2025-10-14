{
  config,
  lib,
  pkgs,
  ...
}: let
  kubernetesTools = import ../../../pkgs/collections/kubernetes-tools.nix {inherit pkgs;};
in {
  options.programs.kube = with lib; {
    enable = mkEnableOption "kubernetes tools configuration";

    toolset = mkOption {
      type = types.enum ["minimal" "admin" "operations" "devops" "security-focused" "mesh" "complete"];
      default = "admin";
      description = ''
        Which set of Kubernetes tools to install:
        - minimal: Core tools only (kubectl, helm, kustomize, kubectx, kubecolor)
        - admin: For cluster administration (core + observability + security)
        - operations: For production cluster management
        - devops: For CI/CD and GitOps workflows
        - security-focused: For cluster security auditing
        - mesh: For service mesh management
        - complete: All available tools
      '';
    };
  };

  config = lib.mkIf config.programs.kube.enable {
    home = {
      packages = kubernetesTools.sets.${config.programs.kube.toolset};

      # Create k9s configuration directory and basic config
      file.".config/k9s/config.yml".text = ''
        k9s:
          # General settings
          refreshRate: 2
          maxConnRetry: 5
          readOnly: false
          noExitOnCtrlC: false
          ui:
            enableMouse: false
            headless: false
            logoless: false
            crumbsless: false
            reactive: true
            noIcons: false
          skipLatestRevCheck: false
          disablePodCounting: false
          shellPod:
            image: busybox:1.35.0
            namespace: default
            limits:
              cpu: 100m
              memory: 100Mi
          imageScans:
            enable: false
            exclusions:
              namespaces: []
              labels: {}
          logger:
            tail: 100
            buffer: 5000
            sinceSeconds: -1
            textWrap: false
            showTime: false
          thresholds:
            cpu:
              critical: 90
              warn: 70
            memory:
              critical: 90
              warn: 70
      '';

      # Create k9s skin configuration for better visuals
      file.".config/k9s/skin.yml".text = ''
        k9s:
          body:
            fgColor: dodgerblue
            bgColor: black
            logoColor: blue
          prompt:
            fgColor: green
            bgColor: black
            suggestColor: white
          info:
            fgColor: lightskyblue
            sectionColor: steelblue
          dialog:
            fgColor: white
            bgColor: steelblue
            buttonFgColor: black
            buttonBgColor: aqua
            buttonFocusFgColor: yellow
            buttonFocusBgColor: hotpink
            labelFgColor: orange
            fieldFgColor: white
          frame:
            border:
              fgColor: dodgerblue
              focusColor: aliceblue
            menu:
              fgColor: white
              keyColor: hotpink
              numKeyColor: fuchsia
            crumbs:
              fgColor: white
              bgColor: steelblue
              activeColor: orange
            status:
              newColor: lightyellow
              modifyColor: greenyellow
              addColor: dodgerblue
              errorColor: lightcoral
              highlightcolor: orange
              killColor: mediumpurple
              completedColor: lightsteelblue
            title:
              fgColor: aqua
              bgColor: white
              highlightColor: orange
              counterColor: slateblue
              filterColor: slategray
          views:
            charts:
              bgColor: default
              defaultDialColors:
                - steelblue
                - orange
              defaultChartColors:
                - steelblue
                - orange
            table:
              fgColor: steelblue
              bgColor: default
              cursorFgColor: black
              cursorBgColor: aqua
              markColor: darkslateblue
            xray:
              fgColor: steelblue
              bgColor: default
              cursorColor: aqua
              graphicColor: darkslateblue
              showIcons: false
            yaml:
              keyColor: steelblue
              colonColor: blue
              valueColor: royalblue
            logs:
              fgColor: white
              bgColor: default
              indicator:
                fgColor: dodgerblue
                bgColor: default
      '';
    };

    # Kubernetes-specific shell configuration
    # Note: kubectl completion is already handled by oh-my-zsh kubectl plugin
    # We just add additional enhancements here
    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable ''
      # Kubecolor integration (colorized kubectl output)
      if command -v kubecolor &> /dev/null; then
        alias kubectl="kubecolor"
        # Make completion work with kubecolor
        compdef kubecolor=kubectl
      fi

      # Helm completion (oh-my-zsh doesn't include this)
      if command -v helm &> /dev/null; then
        source <(helm completion zsh)
        compdef h=helm
      fi

      # Additional kubectl completions for custom aliases
      if command -v kubectl &> /dev/null; then
        # Enable kubectl autocompletion for aliases not covered by oh-my-zsh
        compdef kns=kubectl
        compdef kgaa=kubectl
        compdef kgpsn=kubectl
        compdef krestartpo=kubectl
      fi

      # K9s configuration
      export K9S_CONFIG_DIR="$HOME/.config/k9s"

      # Krew (kubectl plugin manager) path
      export PATH="${config.home.homeDirectory}/.krew/bin:$PATH"
    '';

    # Add bash completion if bash is enabled
    programs.bash.initExtra = lib.mkIf config.programs.bash.enable ''
      # Kubectl completion
      if command -v kubectl &> /dev/null; then
        source <(kubectl completion bash)
      fi

      # Helm completion
      if command -v helm &> /dev/null; then
        source <(helm completion bash)
      fi

      # Kubecolor integration for bash
      if command -v kubecolor &> /dev/null; then
        alias kubectl="kubecolor"
      fi
    '';
  };
}
