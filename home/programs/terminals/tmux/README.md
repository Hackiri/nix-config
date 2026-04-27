Prefixes: C-b (default), C-a (custom prefix2).

General
┌───────┬─────────────────────┬─────────────────┐
│ Key │ Action │ Note │
├───────┼─────────────────────┼─────────────────┤
│ r │ Reload config │ Custom │
│ m │ Toggle mouse │ Custom │
│ Space │ Toggle last session │ sesh last │
│ T │ Sesh connect │ Custom fzf-tmux │
│ C │ Claude popup │ Custom popup │
│ C-l │ Clear history │ Custom │
│ E │ Broadcast command │ Custom prompt │
│ d │ Detach │ Default │
│ : │ Command prompt │ Default │
│ ? │ List all binds │ Default │
│ ~ │ Show messages │ Default │
│ t │ Show clock │ Default │
└───────┴─────────────────────┴─────────────────┘

Sesh FZF (inside Prefix + T)
┌───────┬─────────────────────┬──────────────────┐
│ Key │ Action │ Scope │
├───────┼─────────────────────┼──────────────────┤
│ C-a │ List all │ sesh list │
│ C-t │ List tmux │ sesh list -t │
│ C-g │ List configs │ sesh list -c │
│ C-x │ List zoxide │ sesh list -z │
│ C-f │ Find files │ fd -H ... │
│ C-d │ Kill session │ tmux kill-sess │
└───────┴─────────────────────┴──────────────────┘

Windows & Panes
┌────────────┬────────────────────────────┬───────────────────┐
│ Key │ Action │ Note │
├────────────┼────────────────────────────┼───────────────────┤
│ c │ New window (after current) │ Custom │
│ C │ New window │ Custom │
│ Tab │ Last window │ Custom │
│ C-Tab │ Next window │ No prefix │
│ C-S-Tab │ Previous window │ No prefix │
│ Left │ Swap window left │ Custom (-r) │
│ Right │ Swap window right │ Custom (-r) │
│ " / - │ Split vertical │ Custom │
│ % / | │ Split horizontal │ Custom │
│ h, j, k, l │ Select pane │ Vim-like (Plugin) │
│ H, J, K, L │ Resize pane │ Vim-like (-r) │
│ u, i, o, p │ Jump to window 1-4 │ Custom home-row │
│ Q │ Sync panes │ Custom toggle │
│ z │ Zoom pane │ Default │
│ ! │ Break pane to window │ Default │
│ { / } │ Swap pane Up/Down │ Default │
│ q │ Display pane numbers │ Default │
│ w │ Choose window (list) │ Default │
│ , │ Rename window │ Default │
│ & │ Kill window │ Default │
│ x │ Kill pane │ Default │
└────────────┴────────────────────────────┴───────────────────┘

Sessions & Clients
┌─────┬────────────────┬────────────────┐
│ Key │ Action │ Note │
├─────┼────────────────┼────────────────┤
│ C-n │ New session │ Custom prompt │
│ R │ Rename session │ Custom prompt │
│ C-k │ Kill session │ Custom confirm │
│ $ │ Rename session │ Default │
│ s │ Choose session │ Default │
│ ( │ Prev client │ Default │
│ ) │ Next client │ Default │
│ D │ Detach client │ Default (list) │
└─────┴────────────────┴────────────────┘

Copy Mode (vi)
┌─────────┬──────────────────┬───────────────────────┐
│ Key │ Action │ Note │
├─────────┼──────────────────┼───────────────────────┤
│ Enter │ Enter copy mode │ Custom │
│ M-Enter │ Enter copy mode │ No prefix (Alt+Enter) │
│ v │ Begin selection │ Custom │
│ V │ Select line │ Custom │
│ y │ Copy selection │ Custom │
│ C-v │ Rectangle toggle │ Custom │
│ H │ Start of line │ Custom (Mac ergo) │
│ L │ End of line │ Custom (Mac ergo) │
│ 0 │ Start of line │ Default │
│ $ │ End of line │ Default │
│ [ │ Enter copy mode │ Default │
│ ] │ Paste │ Default │
│ # │ List buffers │ Default │
│ = │ Choose buffer │ Default │
└─────────┴──────────────────┴───────────────────────┘

Layouts
┌─────────┬──────────────────────────┬───────────┐
│ Key │ Action │ Note │
├─────────┼──────────────────────────┼───────────┤
│ M-1 │ Even Horizontal │ Default │
│ M-2 │ Even Vertical │ Default │
│ M-3 │ Main Horizontal │ Default │
│ M-4 │ Main Vertical │ Default │
│ M-5 │ Tiled │ Default │
│ C-o │ Rotate panes │ Default │
└─────────┴──────────────────────────┴───────────┘

Plugin Specifics
┌─────┬─────────────┬────────────────────┐
│ Key │ Action │ Note │
├─────┼─────────────┼────────────────────┤
│ F │ Tmux-thumbs │ Custom (was Space) │
│ U │ Fzf-url │ Custom (was u) │
└─────┴─────────────┴────────────────────┘
