;;; packages.el

;; Themes
(package! nord-theme)
(package! nordless-theme)
(package! vscode-dark-plus-theme)

;; Icons
(package! all-the-icons)
(package! all-the-icons-dired)

;; Linting/Checking
(package! flycheck-pyflakes)
(package! flycheck-pos-tip)

;; AI/Chat
(package! gptel)

;; Editing enhancements
(package! smart-tabs-mode)
(package! whitespace-cleanup-mode)
(package! multiple-cursors)

;; Git integration
(package! glab)

;; Language support
(package! dts-mode)
(package! nickel-mode)
(package! pandoc)

;; Example: Install a package from a custom repo
;; (package! some-package
;;   :recipe (:host github :repo "username/repo"))

;; To unpin or override packages, use:
;; (unpin! pinned-package)
