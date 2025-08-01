;;; init-treemacs.el --- File tree with Treemacs -*- lexical-binding: t; -*-

;;; Commentary:
;; This file configures Treemacs file tree with all-the-icons support,
;; Projectile integration, and enhanced keybindings.

;;; Code:

;; =============================================================================
;; Icons for Treemacs
;; =============================================================================

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p)
  :config
  ;; Only install fonts if they don't exist
  (unless (file-exists-p (expand-file-name "Library/Fonts/all-the-icons.ttf" (getenv "HOME")))
    (all-the-icons-install-fonts t)))

;; Fallback icon theme if all-the-icons fails
(use-package treemacs-icons-dired
  :ensure t
  :after treemacs
  :config
  (treemacs-icons-dired-mode))

;; =============================================================================
;; Treemacs - File Tree
;; =============================================================================

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  ;; Use all-the-icons instead of nerd-icons
  (setq treemacs-icon-theme 'all-the-icons)
  ;; Basic settings
  (setq treemacs-collapse-dirs 3)
  (setq treemacs-deferred-git-apply-delay 0.5)
  (setq treemacs-display-in-side-window t)
  (setq treemacs-file-event-delay 5000)
  (setq treemacs-file-follow-delay 0.2)
  (setq treemacs-follow-after-init t)
  (setq treemacs-git-command-pipe "")
  (setq treemacs-goto-tag-strategy 'refetch-index)
  (setq treemacs-indentation 2)
  (setq treemacs-indentation-string " ")
  (setq treemacs-is-never-other-window nil)
  (setq treemacs-max-git-entries 5000)
  (setq treemacs-no-png-images nil)
  (setq treemacs-no-delete-other-windows t)
  (setq treemacs-project-follow-cleanup nil)
  (setq treemacs-persist-file (expand-file-name ".cache/treemacs-persist" user-emacs-directory))
  (setq treemacs-recenter-distance 0.1)
  (setq treemacs-recenter-after-file-follow nil)
  (setq treemacs-recenter-after-tag-follow nil)
  (setq treemacs-recenter-after-project-jump 'always)
  (setq treemacs-recenter-after-project-expand 'on-distance)
  (setq treemacs-show-cursor nil)
  (setq treemacs-show-hidden-files t)
  (setq treemacs-silent-filewatch nil)
  (setq treemacs-silent-refresh nil)
  (setq treemacs-sorting 'alphabetic-asc)
  (setq treemacs-space-between-root-nodes t)
  (setq treemacs-tag-follow-cleanup t)
  (setq treemacs-tag-follow-delay 1.5)
  (setq treemacs-width 30)
  (setq treemacs-workspace-switch-cleanup 'files)
  
  ;; Icon settings
  (treemacs-resize-icons 16)
  
  ;; Enable file watch
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  
  ;; Enable git integration
  (treemacs-git-mode 'deferred)
  
  ;; Follow mode
  (treemacs-follow-mode t)
  (treemacs-project-follow-mode t)
  
  ;; Ensure icons are loaded when Treemacs starts
  (add-hook 'treemacs-mode-hook 'ensure-treemacs-icons)
  
  :bind
  (:map global-map
        ("<f8>"      . treemacs-toggle)  ; F8 toggle
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

;; =============================================================================
;; Treemacs Projectile Integration
;; =============================================================================

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

;; =============================================================================
;; Ace Window Integration
;; =============================================================================

(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "M-o") 'ace-window)
  ;; Exclude treemacs from ace-window
  (setq aw-ignored-buffers
        (delq nil
              (list " *Treemacs-Framebuffer-1*"
                    " *Treemacs-Scoped-Buffer-Project/.*"
                    "*Treemacs*"))))

;; =============================================================================
;; Helper Functions
;; =============================================================================

(defun ensure-treemacs-icons ()
  "Ensure Treemacs icons are properly loaded."
  (interactive)
  (when (display-graphic-p)
    (if (require 'all-the-icons nil t)
        (progn
          ;; Only install fonts if they don't exist
          (unless (file-exists-p (expand-file-name "Library/Fonts/all-the-icons.ttf" (getenv "HOME")))
            (all-the-icons-install-fonts t)
            (message "All-the-icons fonts installed"))
          (message "All-the-icons fonts ready"))
      (message "All-the-icons not available, using fallback icons"))))

(defun test-treemacs-f8-toggle ()
  "Test that F8 properly toggles Treemacs."
  (interactive)
  (message "F8 keybinding test: Press F8 to toggle Treemacs"))

(defun treemacs-show-current-project ()
  "Show current project in treemacs."
  (interactive)
  (when (and (bound-and-true-p projectile-mode)
             (projectile-project-p))
    (treemacs-display-current-project-exclusively)))

(defun treemacs-add-current-project ()
  "Add current project to treemacs workspace."
  (interactive)
  (when (projectile-project-p)
    (let ((project-path (projectile-project-root))
          (project-name (projectile-project-name)))
      (treemacs-do-add-project-to-workspace project-path project-name))))

(defun projectile-open-project-in-treemacs ()
  "Open current project in treemacs after switching."
  (treemacs-show-current-project))

;; Hook to show current project when switching
(add-hook 'projectile-after-switch-project-hook
          #'projectile-open-project-in-treemacs)

;; =============================================================================
;; Global Keybindings
;; =============================================================================

;; Global keybindings for Treemacs
(global-set-key (kbd "C-c p t") 'treemacs-show-current-project)
(global-set-key (kbd "C-c p a") 'treemacs-add-current-project)

(provide 'init-treemacs)
;;; init-treemacs.el ends here 