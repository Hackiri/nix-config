# Btop - system resource monitor with vim keys and rosepine theme
_: {
  programs.btop = {
    enable = true;

    settings = {
      color_theme = "rosepine"; # since you have rosepine theme
      theme_background = false;
      vim_keys = true;
      rounded_corners = true;
      graph_symbol = "braille";
      update_ms = 1000; # 1 second update time
      proc_sorting = "cpu lazy";
      proc_reversed = false;
      proc_tree = false;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = false;
      show_uptime = true;
      check_temp = true;
      cpu_sensor = "Auto";
      show_coretemp = true;
      temp_scale = "celsius";
      disks_filter = "";
      mem_graphs = true;
      show_swap = true;
      swap_disk = true;
      show_disks = true;
      net_download = true;
      net_upload = true;
      net_auto = true;
      net_sync = true;
      net_iface = "";
    };
  };

  # xdg.configFile."btop/btop.conf".source = ./btop.conf;
  xdg.configFile."btop/themes".source = ./themes;
}
