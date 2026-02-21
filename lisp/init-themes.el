;;; init-themes.el --- Defaults for themes -*- lexical-binding: t -*-
;;; Commentary:
;; Enhanced theme configuration with better toggle functionality, font configuration,
;; macOS integration, and additional theme options.
;;; Code:

(require-package 'doom-themes)

;; Don't prompt to confirm theme safety. This avoids problems with
;; first-time startup on Emacs > 26.3.
(setq custom-safe-themes t)

;; If you don't customize it, this is the theme you get.
(setq-default custom-enabled-themes '(doom-one-light))

;; Ensure that themes will be applied even if they have not been customized
(defun reapply-themes ()
  "Forcibly load the themes listed in `custom-enabled-themes'."
  (dolist (theme custom-enabled-themes)
    (unless (custom-theme-p theme)
      (load-theme theme)))
  (custom-set-variables `(custom-enabled-themes (quote ,custom-enabled-themes))))

(add-hook 'after-init-hook 'reapply-themes)

;; =============================================================================
;; Enhanced Theme Toggle Function
;; =============================================================================

(defun toggle-doom-theme ()
  "Toggle between Doom One light and dark themes."
  (interactive)
  (if (eq (car custom-enabled-themes) 'doom-one-light)
      (progn
        (disable-theme 'doom-one-light)
        (load-theme 'doom-one t)
        (message "Switched to Doom One Dark"))
    (disable-theme 'doom-one)
    (load-theme 'doom-one-light t)
    (message "Switched to Doom One Light")))

;; =============================================================================
;; Original Toggle Functions (Preserved)
;; =============================================================================

(defun light ()
  "Activate a light color theme."
  (interactive)
  (setq custom-enabled-themes '(doom-one-light))
  (reapply-themes))

(defun dark ()
  "Activate a dark color theme."
  (interactive)
  (setq custom-enabled-themes '(doom-one))
  (reapply-themes))

;; =============================================================================
;; Additional Theme Options
;; =============================================================================

(defun switch-to-doom-solarized-light ()
  "Switch to Doom Solarized Light theme."
  (interactive)
  (disable-theme (car custom-enabled-themes))
  (load-theme 'doom-solarized-light t)
  (message "Switched to Doom Solarized Light"))

(defun switch-to-doom-solarized-dark ()
  "Switch to Doom Solarized Dark theme."
  (interactive)
  (disable-theme (car custom-enabled-themes))
  (load-theme 'doom-solarized-dark t)
  (message "Switched to Doom Solarized Dark"))

(defun switch-to-doom-dracula ()
  "Switch to Doom Dracula theme (dark)."
  (interactive)
  (disable-theme (car custom-enabled-themes))
  (load-theme 'doom-dracula t)
  (message "Switched to Doom Dracula"))

(defun switch-to-doom-nord ()
  "Switch to Doom Nord theme (dark)."
  (interactive)
  (disable-theme (car custom-enabled-themes))
  (load-theme 'doom-nord t)
  (message "Switched to Doom Nord"))

;; =============================================================================
;; Font Configuration
;; =============================================================================

(defun setup-programming-fonts ()
  "Set up programming fonts with ligatures support."
  (cond
   ;; Try Fira Code first (excellent programming font with ligatures)
   ((find-font (font-spec :name "Fira Code"))
    (set-face-attribute 'default nil
                        :family "Fira Code"
                        :height 140
                        :weight 'normal))
   ;; Fall back to JetBrains Mono
   ((find-font (font-spec :name "JetBrains Mono"))
    (set-face-attribute 'default nil
                        :family "JetBrains Mono"
                        :height 140
                        :weight 'normal))
   ;; Fall back to SF Mono on macOS
   ((and (eq system-type 'darwin)
         (find-font (font-spec :name "SF Mono")))
    (set-face-attribute 'default nil
                        :family "SF Mono"
                        :height 140
                        :weight 'normal))
   ;; Final fallback to Inconsolata
   ((find-font (font-spec :name "Inconsolata"))
    (set-face-attribute 'default nil
                        :family "Inconsolata"
                        :height 140
                        :weight 'normal))))

;; Configure font for Unicode characters
;; (defun setup-unicode-font ()
;;   "Set up Unicode font for special characters."
;;   (when (find-font (font-spec :name "Symbola"))
;;     (set-fontset-font t 'unicode "Symbola" nil 'prepend)))

;; =============================================================================
;; Frame and Window Appearance
;; =============================================================================

(defun setup-frame-appearance ()
  "Set up frame appearance settings."
  ;; Set default frame parameters
  (setq default-frame-alist
        '((width . 120)
          (height . 40)
          (left . 100)
          (top . 100)))
  
  ;; macOS specific appearance settings
  (when (eq system-type 'darwin)
    ;; Use native fullscreen
    (setq ns-use-native-fullscreen t)
    ;; Transparent title bar
    (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
    ;; Dark appearance for title bar
    (add-to-list 'default-frame-alist '(ns-appearance . dark))))

;; =============================================================================
;; Time-based Theme Switching (Optional)
;; =============================================================================

(defun auto-switch-theme ()
  "Automatically switch theme based on time of day."
  (let ((hour (string-to-number (format-time-string "%H"))))
    (if (and (>= hour 6) (< hour 18))
        (load-theme 'doom-one-light t)
      (load-theme 'doom-one t))))

;; Uncomment to enable automatic theme switching
;; (auto-switch-theme)
;; (run-with-timer 0 (* 60 60) 'auto-switch-theme)

;; =============================================================================
;; Theme Integration
;; =============================================================================

;; Enable custom neotree theme (if using neotree)
(defun setup-doom-theme-integrations ()
  "Set up Doom theme integrations for various packages."
  (doom-themes-neotree-config)
  (doom-themes-org-config)
  (doom-themes-treemacs-config))

;; =============================================================================
;; Keybindings
;; =============================================================================

;; Global keybindings for theme switching
(global-set-key (kbd "M-<f12>") 'toggle-doom-theme)
(global-set-key (kbd "C-c t t") 'toggle-doom-theme)
(global-set-key (kbd "C-c t 1") 'switch-to-doom-one)
(global-set-key (kbd "C-c t s") 'switch-to-doom-solarized-light)
(global-set-key (kbd "C-c t S") 'switch-to-doom-solarized-dark)
(global-set-key (kbd "C-c t d") 'switch-to-doom-dracula)
(global-set-key (kbd "C-c t n") 'switch-to-doom-nord)

;; =============================================================================
;; Initialize Enhanced Theme System
;; =============================================================================

(add-hook 'after-init-hook
          (lambda ()
            ;; Font setup moved to init-gui-frames.el to avoid conflicts
            ;; (setup-unicode-font)
            (setup-frame-appearance)
            (setup-doom-theme-integrations)))

;; =============================================================================
;; Dimmer Configuration (Preserved)
;; =============================================================================

(when (maybe-require-package 'dimmer)
  (setq-default dimmer-fraction 0.15)
  (add-hook 'after-init-hook 'dimmer-mode)
  (with-eval-after-load 'dimmer
    ;; TODO: file upstream as a PR
    (advice-add 'frame-set-background-mode :after (lambda (&rest args) (dimmer-process-all))))
  (with-eval-after-load 'dimmer
    ;; Don't dim in terminal windows. Even with 256 colours it can
    ;; lead to poor contrast.  Better would be to vary dimmer-fraction
    ;; according to frame type.
    (defun sanityinc/display-non-graphic-p ()
      (not (display-graphic-p)))
    (add-to-list 'dimmer-exclusion-predicates 'sanityinc/display-non-graphic-p)))

(provide 'init-themes)
;;; init-themes.el ends here
