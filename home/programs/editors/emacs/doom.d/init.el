;;; init.el -*- lexical-binding: t; -*-

(doom! 
 :input
 ;;bidi

 :completion
 (company +childframe +tng)
 (vertico +icons)

 :ui
 doom
 doom-dashboard
 doom-quit
 (emoji +unicode)
 hl-todo
 ligatures
 modeline
 ophints
 (popup +defaults)
 treemacs
 vc-gutter
 vi-tilde-fringe
 window-select
 workspaces
 zen

 :editor
 (evil +everywhere)
 file-templates
 fold
 (format +onsave)
 snippets

 :emacs
 (dired +icons)
 electric
 undo
 vc

 :term
 vterm

 :checkers
 (syntax +flymake)  ; Use flymake instead of flycheck for Emacs 31 compatibility
 spell
 grammar

 :tools
 direnv
 (eval +overlay)
 lookup
 (lsp +peek)
 (magit +forge)
 pdf
 rgb
 ;; tree-sitter  ; Not needed - Emacs 31 has built-in tree-sitter support

 :os
 macos

 :lang
 emacs-lisp
 (json +lsp)
 (python +lsp +pyright)
 (javascript +lsp +tree-sitter)
 (typescript +lsp +tree-sitter)
 web
 (org +roam +journal)
 markdown
 sh
 yaml

 :email
 ;;(mu4e +gmail)
 ;;notmuch

 :app
 ;;calendar
 ;;irc
 ;;rss
 ;;twitter

 :config
 (default +bindings +smartparens))
