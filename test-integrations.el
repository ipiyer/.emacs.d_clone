;;; test-integrations.el --- Test script for enhanced integrations -*- lexical-binding: t; -*-

;;; Commentary:
;; This file provides test functions to verify that all enhanced integrations
;; (Projectile, Theme, Treemacs) are working properly.

;;; Code:

(defun test-enhanced-projectile ()
  "Test enhanced Projectile functionality."
  (interactive)
  (message "=== Testing Enhanced Projectile ===")
  
  ;; Test basic Projectile
  (if (bound-and-true-p projectile-mode)
      (message "✓ Projectile mode is enabled")
    (message "✗ Projectile mode is not enabled"))
  
  ;; Test ibuffer-projectile
  (if (require 'ibuffer-projectile nil t)
      (message "✓ ibuffer-projectile is available")
    (message "✗ ibuffer-projectile is not available"))
  
  ;; Test project detection
  (if (projectile-project-p)
      (message "✓ Currently in a projectile project: %s" (projectile-project-name))
    (message "ℹ Not currently in a projectile project"))
  
  ;; Test keybindings
  (message "Keybindings to test:")
  (message "  C-c p f - Find file in project")
  (message "  C-c p b - Enhanced ibuffer")
  (message "  C-c p B - Project buffers only")
  (message "  C-c p r - Create README")
  (message "  C-c p i - Create .gitignore"))

(defun test-enhanced-themes ()
  "Test enhanced theme functionality."
  (interactive)
  (message "=== Testing Enhanced Themes ===")
  
  ;; Test Doom themes
  (if (require 'doom-themes nil t)
      (message "✓ Doom themes are available")
    (message "✗ Doom themes are not available"))
  
  ;; Test current theme
  (message "✓ Current theme: %s" (car custom-enabled-themes))
  
  ;; Test font setup
  (message "✓ Default font: %s" (face-attribute 'default :family))
  
  ;; Test keybindings
  (message "Keybindings to test:")
  (message "  M-<f12> - Toggle theme")
  (message "  C-c t t - Toggle theme")
  (message "  C-c t 1 - Switch to Doom One")
  (message "  C-c t s - Switch to Solarized Light")
  (message "  C-c t S - Switch to Solarized Dark")
  (message "  C-c t d - Switch to Dracula")
  (message "  C-c t n - Switch to Nord"))

(defun test-treemacs ()
  "Test Treemacs functionality."
  (interactive)
  (message "=== Testing Treemacs ===")
  
  ;; Test Treemacs package
  (if (require 'treemacs nil t)
      (message "✓ Treemacs is available")
    (message "✗ Treemacs is not available"))
  
  ;; Test all-the-icons
  (if (require 'all-the-icons nil t)
      (message "✓ all-the-icons is available")
    (message "✗ all-the-icons is not available"))
  
  ;; Test treemacs-projectile
  (if (require 'treemacs-projectile nil t)
      (message "✓ treemacs-projectile is available")
    (message "✗ treemacs-projectile is not available"))
  
  ;; Test ace-window
  (if (require 'ace-window nil t)
      (message "✓ ace-window is available")
    (message "✗ ace-window is not available"))
  
  ;; Test keybindings
  (message "Keybindings to test:")
  (message "  F8 - Toggle Treemacs")
  (message "  M-0 - Select Treemacs window")
  (message "  M-o - Ace window (excludes Treemacs)")
  (message "  C-c p t - Show current project in Treemacs")
  (message "  C-c p a - Add current project to Treemacs"))

(defun test-all-integrations ()
  "Test all enhanced integrations."
  (interactive)
  (message "=== Testing All Enhanced Integrations ===")
  (test-enhanced-projectile)
  (message "")
  (test-enhanced-themes)
  (message "")
  (test-treemacs)
  (message "")
  (message "=== Integration Test Complete ===")
  (message "Check the messages above for any issues.")
  (message "All keybindings should be available for testing."))

;; Global keybindings for testing
(global-set-key (kbd "C-c t p") 'test-enhanced-projectile)
(global-set-key (kbd "C-c t h") 'test-enhanced-themes)
(global-set-key (kbd "C-c t r") 'test-treemacs)
(global-set-key (kbd "C-c t a") 'test-all-integrations)

(provide 'test-integrations)
;;; test-integrations.el ends here 