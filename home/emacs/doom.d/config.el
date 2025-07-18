;;; config.el -*- lexical-binding: t; -*-

;; User identity
(setq user-full-name "hackiri"
      user-mail-address "128340174+Hackiri@users.noreply.github.com")

;; Font settings
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 12)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 12)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 16)) ;; For presentations or streaming

;; Set fixed-pitch font for code blocks in org-mode, markdown, etc.
(setq doom-unicode-font (font-spec :family "Noto Sans"))

;; Prevent font caches from being garbage collected
(setq inhibit-compacting-font-caches t)

;; Theme
(setq doom-theme 'doom-nord)

;; Line numbers
(setq display-line-numbers-type 'relative)

;; Org directory
(setq org-directory "~/org/")

;; UI/UX tweaks
(setq confirm-kill-emacs nil) ; Don't prompt on quit

;; Configure Nerd Icons to use JetBrainsMono Nerd Font
(after! nerd-icons
  (setq nerd-icons-font-family "JetBrainsMono Nerd Font")
  (setq nerd-icons-font-names '("JetBrainsMono Nerd Font")))


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

;; Custom functions from traditional config

;; Unfill paragraph - opposite of fill-paragraph
(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph REGION and make it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

;; Handy key definition for unfill-paragraph
(map! "M-Q" #'unfill-paragraph)

;; Unfill region function
(defun unfill-region ()
  "Unfills a region."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-region (region-beginning) (region-end) nil)))

;; DOS to UNIX line endings conversion
(defun dos2unix()
  "Convert this entire buffer from MS-DOS text file format to UNIX."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "\r$" "" nil)
    (goto-char (1- (point-max)))
    (if (looking-at "\C-z")
        (delete-char 1))))

;; Word count function
(defun word-count nil 
  "Count words in buffer." 
  (interactive)
  (shell-command-on-region (point-min) (point-max) "wc -w"))

;; Join next line (like vi's "J")
(defun join-next-line ()
  "Join next line."
  (interactive)
  (join-line 1))

;; Multiple cursors setup
(use-package! multiple-cursors
  :config
  (map! "C-S-l" #'mc/mark-all-like-this))

;; Enhanced dired customizations
(after! dired
  ;; Allow dired-find-alternate-file
  (put 'dired-find-alternate-file 'disabled nil)
  
  ;; Ispell function for dired
  (defun dired-do-ispell (&optional arg)
    "Do ispell from Dired. Takes ARG."
    (interactive "P")
    (dolist (file (dired-get-marked-files
                   nil arg
                   #'(lambda (f)
                       (not (file-directory-p f)))))
      (save-window-excursion
        (with-current-buffer (find-file file)
          (ispell-buffer)))
      (message nil)))
  
  ;; Configure dired-x after dired is loaded
  (require 'dired-x)
  (setq dired-omit-mode t)
  
  ;; Add custom extensions to omit list
  (add-hook 'dired-mode-hook
            (lambda ()
              ;; Add patterns to omit
              (when (boundp 'dired-omit-files)
                (setq dired-omit-files
                      (concat dired-omit-files "\\|^\\..+$\\|__pycache__")))
              ;; Add extensions to omit
              (when (boundp 'dired-omit-extensions)
                (setq dired-omit-extensions
                      (append '(".pyc" ".pyo" ".bak" ".cache" ".pt.py" "html.py")
                              dired-omit-extensions))))))

;; File backup settings
(defvar backup-dir "~/.doom.d/backups")
(make-directory backup-dir t)

(setq backup-directory-alist
      `((".*" . ,backup-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,backup-dir t)))

;; Don't ask if we should follow symlinks
(setq vc-follow-symlinks t)

;; Additional key bindings using Doom's map! macro
(map! 
  "C-z" #'undo
  [delete] #'delete-char
  [kp-delete] #'delete-char
  "M-g" #'goto-line
  "C-q" #'query-replace
  "C-j" #'join-next-line
  "<f5>" #'compile)

;; Additional customizations go here...

;; Display buffer configuration optimized for screen real estate
(setq display-buffer-alist
      '(
        ;; Side windows for help, compilation, etc.
        ("\*Help\*"
         (display-buffer-reuse-window display-buffer-in-side-window)
         (side . right)
         (window-width . 0.33)
         (reusable-frames . visible))
        
        ;; Documentation in side window
        ((or "\*info\*" "\*Apropos\*" "\*eldoc\*")
         (display-buffer-reuse-window display-buffer-in-side-window)
         (side . right)
         (window-width . 0.33)
         (reusable-frames . visible))
        
        ;; Keep compilation in bottom window
        ("\*compilation\*"
         (display-buffer-reuse-window display-buffer-in-direction)
         (direction . bottom)
         (window-height . 0.25)
         (reusable-frames . visible))
        
        ;; REPLs and terminals in bottom window
        ((or "\*\(?:shell\|term\|vterm\)\*" "\*Python\*" "\*R\*")
         (display-buffer-reuse-window display-buffer-at-bottom)
         (window-height . 0.25)
         (reusable-frames . visible))
        
        ;; Magit status in same window
        ("\*magit: .*\*"
         (display-buffer-same-window))
        
        ;; Magit process in bottom window
        ("\*magit-process\*"
         (display-buffer-reuse-window display-buffer-at-bottom)
         (window-height . 0.2)
         (reusable-frames . visible))
        
        ;; Org source blocks in other window
        ("\*Org Src.*\*"
         (display-buffer-reuse-window display-buffer-use-some-window)
         (inhibit-same-window . t))
        
        ;; Keep grep/search results in other window
        ((or "\*grep\*" "\*ag search\*" "\*rg\*" "\*deadgrep\*")
         (display-buffer-reuse-window display-buffer-in-direction)
         (direction . right)
         (window-width . 0.5)
         (reusable-frames . visible))
        
        ;; Keep error lists in bottom window
        ((or "\*Flycheck errors\*" "\*Flymake diagnostics.*\*")
         (display-buffer-reuse-window display-buffer-in-direction)
         (direction . bottom)
         (window-height . 0.15)
         (reusable-frames . visible))
        ))

;; Prevent windows from being automatically resized
(setq even-window-sizes nil)

;; Prevent splitting windows when they become too narrow
(setq split-width-threshold 160)
(setq split-height-threshold 80)

