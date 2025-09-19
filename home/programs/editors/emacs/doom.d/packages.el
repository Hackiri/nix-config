;;; packages.el

;; Git integration packages that require custom recipes
(package! glab)
(package! gtea :recipe (:host github :repo "emacsmirror/gtea"))
(package! gogs :recipe (:host github :repo "emacsmirror/gogs"))
(package! buck :recipe (:host github :repo "emacsmirror/buck"))

;; Additional functionality
(package! multiple-cursors)

;; To unpin or override packages, use:
;; (unpin! pinned-package)