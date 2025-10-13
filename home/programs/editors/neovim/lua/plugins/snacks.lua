-- Documentation:
-- https://github.com/folke/snacks.nvim/blob/main/docs/lazygit.md
-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
-- https://github.com/folke/snacks.nvim/blob/main/docs/image.md

-- NOTE: If you experience an issue where you cannot select a file with the
-- snacks picker when you're in insert mode (only in normal mode), and you use
-- the bullets.vim plugin, that's the cause. See:
-- https://github.com/folke/snacks.nvim/issues/812

return {
    -- HACK: docs @ https://github.com/folke/snacks.nvim/blob/main/docs
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        -- NOTE: Options
        opts = {
            styles = {
                input = {
                    keys = {
                        n_esc = { "<C-c>", { "cmp_close", "cancel" }, mode = "n", expr = true },
                        i_esc = { "<C-c>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
                    },
                },
                -- Keep images in top right corner to avoid blocking text
                snacks_image = {
                    relative = "editor",
                    col = -1,
                },
            },
            -- Snacks Modules
            input = {
                enabled = true,
            },
            quickfile = {
                enabled = true,
                exclude = { "latex" },
            },
            bigfile = {
                enabled = true,
                size = 1024 * 1024 * 1.5, -- 1.5MB
            },
            words = {
                enabled = true,
            },
            statuscolumn = {
                enabled = true,
            },
            scroll = {
                enabled = true,
            },
            scope = {
                enabled = true,
            },
            zen = {
                enabled = true,
            },
            dim = {
                enabled = true,
            },
            git = {
                enabled = true,
            },
            gitbrowse = {
                enabled = true,
            },
            -- Indent guides
            indent = {
                enabled = true,
                char = "│",
                blank = " ",
                priority = 1,
                filter = function(buf)
                    local filetype = vim.bo[buf].filetype
                    local exclude_fts = {
                        "help", "alpha", "dashboard", "neo-tree", "Trouble",
                        "lazy", "mason", "notify", "toggleterm", "lazyterm",
                    }
                    return not vim.tbl_contains(exclude_fts, filetype)
                end,
            },
            -- Notifications
            notifier = {
                enabled = true,
                top_down = false,
            },
            -- Lazygit fullscreen config
            lazygit = {
                theme = {
                    selectedLineBgColor = { bg = "CursorLine" },
                },
                win = {
                    width = 0,
                    height = 0,
                },
            },
            -- HACK: read picker docs @ https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
            picker = {
                enabled = true,
                matcher = {
                    frecency = true,
                },
                formatters = {
                    file = {
                        filename_first = true,
                        filename_only = false,
                        icon_width = 2,
                        truncate = 80,
                    },
                },
                -- Score manipulation for frecency
                transform = function(item)
                    if not item.file then return item end
                    -- Example: demote certain files
                    -- if item.file:match("pattern") then
                    --     item.score_add = (item.score_add or 0) - 30
                    -- end
                    return item
                end,
                debug = {
                    scores = false,
                },
                -- Global window keybindings
                win = {
                    input = {
                        keys = {
                            ["<Esc>"] = { "close", mode = { "n", "i" } },
                            ["J"] = { "preview_scroll_down", mode = { "i", "n" } },
                            ["K"] = { "preview_scroll_up", mode = { "i", "n" } },
                            ["H"] = { "preview_scroll_left", mode = { "i", "n" } },
                            ["L"] = { "preview_scroll_right", mode = { "i", "n" } },
                        },
                    },
                },
                layout = {
                    -- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
                    -- override picker layout in keymaps function as a param below
                    preset = "telescope", -- defaults to this layout unless overidden
                    cycle = false,
                },
                layouts = {
                    select = {
                            preview = false,
                            layout = {
                                backdrop = false,
                                width = 0.6,
                                min_width = 80,
                                height = 0.4,
                                min_height = 10,
                                box = "vertical",
                                border = "rounded",
                                title = "{title}",
                                title_pos = "center",
                                { win = "input", height = 1, border = "bottom" },
                                { win = "list", border = "none" },
                                { win = "preview", title = "{preview}", width = 0.6, height = 0.4, border = "top" },
                        }
                    },
                    telescope = {
                        reverse = true, -- set to false for search bar to be on top 
                        layout = {
                            box = "horizontal",
                            backdrop = false,
                            width = 0.8,
                            height = 0.9,
                            border = "none",
                            {
                                box = "vertical",
                                { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
                                { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
                            },
                            {
                                win = "preview",
                                title = "{preview:Preview}",
                                width = 0.50,
                                border = "rounded",
                                title_pos = "center",
                            },
                        },
                    },
                    ivy = {
                        layout = {
                            box = "vertical",
                            backdrop = false,
                            width = 0,
                            height = 0.4,
                            position = "bottom",
                            border = "top",
                            title = " {title} {live} {flags}",
                            title_pos = "left",
                            { win = "input", height = 1, border = "bottom" },
                            {
                                box = "horizontal",
                                { win = "list", border = "none" },
                                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
                            },
                        },
                    },
                }
            },
            image = {
                enabled = true,
                doc = {
                    float = true, -- show image on cursor hover
                    inline = false, -- show image inline
                    max_width = 50,
                    max_height = 30,
                    wo = {
                        wrap = false,
                    },
                },
                convert = {
                    notify = true,
                    command = "magick"
                },
                img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments","Archives/All-Vault-Images/", "~/Library", "~/Downloads" },
            },
        },
        -- NOTE: Keymaps
        keys = {
            -- Disable explorer keymap (conflicts with mini.files)
            { "<leader>e", false },

            -- General
            { "<leader>lg", function() require("snacks").lazygit() end, desc = "Lazygit" },
            { "<leader>rN", function() require("snacks").rename.rename_file() end, desc = "Fast Rename Current File" },
            { "<leader>dB", function() require("snacks").bufdelete() end, desc = "Delete or Close Buffer  (Confirm)" },

            -- Git
            {
                "<leader>gl",
                function()
                    Snacks.picker.git_log({
                        finder = "git_log",
                        format = "git_log",
                        preview = "git_show",
                        confirm = "git_checkout",
                        layout = "vertical",
                    })
                end,
                desc = "Git Log",
            },
            { "<M-b>", function() Snacks.picker.git_branches({ layout = "select" }) end, desc = "Git Branches" },

            -- File Navigation
            { "<leader>pf", function() require("snacks").picker.files() end, desc = "Find Files (Snacks Picker)" },
            { "<leader><space>", function()
                Snacks.picker.files({
                    finder = "files",
                    format = "file",
                    show_empty = true,
                    supports_live = true,
                })
            end, desc = "Find Files" },
            { "<leader>pc", function() require("snacks").picker.files({ cwd = "~/dotfiles/nvim/.config/nvim/lua" }) end, desc = "Find Config File" },

            -- Buffer Navigation with delete functionality
            {
                "<S-h>",
                function()
                    Snacks.picker.buffers({
                        on_show = function() vim.cmd.stopinsert() end,
                        finder = "buffers",
                        format = "buffer",
                        hidden = false,
                        unloaded = true,
                        current = true,
                        sort_lastused = true,
                        win = {
                            input = { keys = { ["d"] = "bufdelete" } },
                            list = { keys = { ["d"] = "bufdelete" } },
                        },
                    })
                end,
                desc = "Buffers (with delete)",
            },

            -- Search
            { "<leader>ps", function() require("snacks").picker.grep() end, desc = "Grep word" },
            { "<leader>pws", function() require("snacks").picker.grep_word() end, desc = "Search Visual selection or Word", mode = { "n", "x" } },

            -- Task Search (incomplete tasks)
            {
                "<leader>tt",
                function()
                    Snacks.picker.grep({
                        prompt = " ",
                        search = "^\\s*- \\[ \\]",
                        regex = true,
                        live = false,
                        dirs = { vim.fn.getcwd() },
                        args = { "--no-ignore" },
                        on_show = function() vim.cmd.stopinsert() end,
                        finder = "grep",
                        format = "file",
                        show_empty = true,
                        supports_live = false,
                        layout = "ivy",
                    })
                end,
                desc = "Search incomplete tasks",
            },

            -- Task Search (completed tasks)
            {
                "<leader>tc",
                function()
                    Snacks.picker.grep({
                        prompt = " ",
                        search = "^\\s*- \\[x\\] `done:",
                        regex = true,
                        live = false,
                        dirs = { vim.fn.getcwd() },
                        args = { "--no-ignore" },
                        on_show = function() vim.cmd.stopinsert() end,
                        finder = "grep",
                        format = "file",
                        show_empty = true,
                        supports_live = false,
                        layout = "ivy",
                    })
                end,
                desc = "Search completed tasks",
            },

            -- Utilities
            { "<M-k>", function() Snacks.picker.keymaps({ layout = "vertical" }) end, desc = "Keymaps" },
            { "<leader>pk", function() require("snacks").picker.keymaps({ layout = "ivy" }) end, desc = "Search Keymaps (Snacks Picker)" },
            { "<leader>th" , function() require("snacks").picker.colorschemes({ layout = "ivy" }) end, desc = "Pick Color Schemes"},
            { "<leader>vh", function() require("snacks").picker.help() end, desc = "Help Pages" },

            -- Zen mode
            { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },

            -- Git browse
            { "<leader>gb", function() Snacks.gitbrowse() end, desc = "Git Browse (Open in Browser)", mode = { "n", "x" } },

            -- Scope navigation
            { "]]", function() Snacks.scope.jump({ direction = "next" }) end, desc = "Jump to Next Scope" },
            { "[[", function() Snacks.scope.jump({ direction = "prev" }) end, desc = "Jump to Previous Scope" },
        },
        config = function(_, opts)
            require("snacks").setup(opts)
            -- Set vim.notify to use Snacks.notifier (replaces nvim-notify)
            vim.notify = function(msg, level, notify_opts)
                return require("snacks").notify(msg, { level = level, opts = notify_opts })
            end
        end,
    },
    -- NOTE: todo comments w/ snacks
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPre", "BufNewFile" },
        optional = true,
        keys = {
            { "<leader>pt", function() require("snacks").picker.todo_comments() end, desc = "Todo" },
            { "<leader>pT", function() require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
        },
    }
}