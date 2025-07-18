;;; init.el -*- lexical-binding: t; -*-

(doom! 
 :input
 ;;bidi

 :completion
 (company +childframe)
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
 format
 snippets

 :emacs
 (dired +icons)
 electric
 undo
 vc

 :term
 vterm

 :checkers
 syntax
 spell
 grammar

 :tools
 (eval +overlay)
 lookup
 lsp
 (magit +forge)
 pdf
 rgb

 :os
 macos

 :lang
 emacs-lisp
 (json +lsp)
 (python +lsp +pyright)
 (javascript +lsp)
 (typescript +lsp)
 web
 (org +roam2 +journal)
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
