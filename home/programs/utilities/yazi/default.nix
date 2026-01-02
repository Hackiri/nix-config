_: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      mgr = {
        show_hidden = true;
        ratio = [1 2 5];
      };
      theme = {
        mgr = {
          tab_normal.bg = {hex = "#282a36";};
          tab_normal.fg = {hex = "#6272a4";};
          tab_select.bg = {hex = "#282a36";};
          tab_select.fg = {hex = "#8be9fd";};
          border_symbol = "│";
          border_style.fg = {hex = "#8be9fd";};
          selection.bg = {hex = "#8be9fd";};
          selection.fg = {hex = "#f8f8f2";};
          status_normal.bg = {hex = "#282a36";};
          status_normal.fg = {hex = "#44475a";};
          status_select.bg = {hex = "#8be9fd";};
          status_select.fg = {hex = "#f8f8f2";};
          folder.fg = {hex = "#8be9fd";};
          link.fg = {hex = "#50fa7b";};
          exec.fg = {hex = "#50fa7b";};
        };
        preview = {
          hovered.bg = {hex = "#44475a";};
          hovered.fg = {hex = "#f8f8f2";};
        };
        input = {
          border.fg = {hex = "#8be9fd";};
          title.fg = {hex = "#44475a";};
          value.fg = {hex = "#f8f8f2";};
          selected.bg = {hex = "#8be9fd";};
        };
        completion = {
          border.fg = {hex = "#8be9fd";};
          selected.bg = {hex = "#8be9fd";};
        };
        tasks = {
          border.fg = {hex = "#8be9fd";};
          selected.bg = {hex = "#8be9fd";};
        };
        which = {
          mask.bg = {hex = "#282a36";};
          desc.fg = {hex = "#6272a4";};
          selected.bg = {hex = "#8be9fd";};
          selected.fg = {hex = "#f8f8f2";};
        };
      };
    };
  };
}
