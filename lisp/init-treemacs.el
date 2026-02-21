;;; init-treemacs.el --- File tree with Treemacs -*- lexical-binding: t; -*-

;;; Commentary:
;; This file configures Treemacs file tree with nerd-icons support,
;; Projectile integration, and enhanced keybindings.

;;; Code:

;; =============================================================================
;; Icons for Treemacs
;; =============================================================================

(use-package nerd-icons
  :ensure t
  :if (display-graphic-p))

;; Treemacs icons for dired
(use-package treemacs-nerd-icons
  :ensure t
  :after (treemacs nerd-icons)
  :config
  (treemacs-load-theme "nerd-icons"))

;; Dired integration
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
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  ;; Use nerd-icons theme
  (setq treemacs-icon-theme 'nerd-icons)
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

(when (maybe-require-package 'ace-window)
  ;; Bind ace-window to both C-x o and M-o
  (global-set-key (kbd "M-o") 'ace-window)
  (global-set-key (kbd "C-x o") 'ace-window)

  ;; Customize ace-window appearance
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))  ; Use home row keys
  (setq aw-scope 'frame)  ; Only show windows in current frame
  (setq aw-background t)  ; Dim background when selecting
  (setq aw-dispatch-always nil)  ; Only show dispatch menu with 1 window
  (setq aw-ignore-on t)  ; Enable ignoring buffers

  ;; Exclude Treemacs buffers from ace-window
  ;; Since aw-ignored-buffers uses exact string matching, we need to list specific buffer names
  ;; and also advice the aw-ignored-p function to handle pattern matching
  (with-eval-after-load 'ace-window
    (setq aw-ignored-buffers
          (append aw-ignored-buffers
                  '("*Treemacs*"
                    " *Treemacs-Framebuffer-1*"
                    " *Treemacs-Framebuffer-2*"
                    " *Treemacs-Scoped-Buffer*")))

    ;; Advice to handle any Treemacs buffer name pattern
    (defun sanityinc/ace-window-ignore-treemacs-advice (orig-fun window)
      "Advice to ignore all Treemacs windows."
      (or (funcall orig-fun window)
          (string-match-p "^[* ]?Treemacs" (buffer-name (window-buffer window)))))

    (advice-add 'aw-ignored-p :around #'sanityinc/ace-window-ignore-treemacs-advice)))

;; =============================================================================
;; Helper Functions
;; =============================================================================

(defun ensure-treemacs-icons ()
  "Ensure Treemacs icons are properly loaded."
  (interactive)
  (when (display-graphic-p)
    (if (require 'nerd-icons nil t)
        (progn
          (message "Nerd-icons loaded successfully")
          ;; Check if fonts are installed by testing for a common nerd-icons font
          (unless (find-font (font-spec :name "Symbols Nerd Font Mono"))
            (message "Nerd-icons fonts may not be installed. Run M-x nerd-icons-install-fonts")))
      (message "Nerd-icons not available, using fallback icons"))))

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
