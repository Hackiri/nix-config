;;; config.el -*- lexical-binding: t; -*-

;; User identity
(setq user-full-name "hackiri"
      user-mail-address "128340174+Hackiri@users.noreply.github.com")

;; Font settings
(setq doom-font (font-spec :family "JetBrainsMono NFM" :size 22)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono NFM" :size 22)
      doom-big-font (font-spec :family "JetBrainsMono NFM" :size 28)) ;; For presentations or streaming

;; Theme
(setq doom-theme 'doom-nord)

;; Line numbers
(setq display-line-numbers-type 'relative)

;; Org directory
(setq org-directory "~/org/")

;; UI/UX tweaks
(setq confirm-kill-emacs nil) ; Don't prompt on quit

;; Language-specific settings
(after! web-mode
  (setq web-mode-markup-indent-offset 2))

(setq js-indent-level 4)

(after! python
  (font-lock-add-keywords 'python-mode
    '(("\\<\\(FIXME\\|HACK\\|XXX\\|TODO\\)" 1 font-lock-warning-face prepend))))

(after! cc-mode
  (setq c-basic-offset 4
        c-indent-level 4))

;; File associations
(dolist (pair
         '(("\\.zcml$"   . nxml-mode)
           ("\\.xml$"    . nxml-mode)
           ("\\.mxml$"   . nxml-mode)
           ("\\.zpt$"    . web-mode)
           ("\\.pt$"     . web-mode)
           ("\\.jinja2$" . web-mode)
           ("\\.html$"   . web-mode)
           ("\\.rst$"    . rst-mode)
           ("\\.rest$"   . rst-mode)))
  (add-to-list 'auto-mode-alist pair))

;; Custom key bindings
(map! :n "C-j" #'join-line
      :n "C-z" #'undo
      :n "M-g" #'goto-line
      :n "C-q" #'query-replace)

;; Package-specific configuration
(after! gptel
  (setq gptel-model "gpt-4"))

;; Additional customizations go here...
