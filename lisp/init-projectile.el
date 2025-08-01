;;; init-projectile.el --- Use Projectile for navigation within projects -*- lexical-binding: t -*-
;;; Commentary:
;; Enhanced Projectile configuration with ibuffer integration, advanced project
;; detection, and additional helper functions.
;;; Code:

(when (maybe-require-package 'projectile)
  (add-hook 'after-init-hook 'projectile-mode)

  ;; Shorter modeline
  (setq-default projectile-mode-line-prefix " Proj")

  (when (executable-find "rg")
    (setq-default projectile-generic-command "rg --files --hidden -0"))

  ;; Enhanced project detection
  (setq projectile-project-search-path '("~/Projects/" "~/work/" "~/src/"))
  
  ;; Performance optimizations
  (setq projectile-indexing-method 'alien)
  (setq projectile-enable-caching t)
  
  ;; Completion system - use default for better fuzzy search
  (setq projectile-completion-system 'default)
  
  ;; Sort files by recently active
  (setq projectile-sort-order 'recently-active)
  
  ;; Ignore certain directories globally
  (setq projectile-globally-ignored-directories
        '("node_modules" ".venv" "venv" "__pycache__" ".pytest_cache" ".mypy_cache"))
  
  ;; Switch project action
  (setq projectile-switch-project-action #'projectile-find-file)

  (with-eval-after-load 'projectile
    (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
    
    ;; Configure project types
    (projectile-register-project-type 'npm '("package.json")
                                      :compile "npm run build"
                                      :test "npm test"
                                      :run "npm start"
                                      :test-prefix "test_"
                                      :test-suffix "_test")
    
    (projectile-register-project-type 'python-pip '("requirements.txt")
                                      :compile "python setup.py build"
                                      :test "python -m pytest"
                                      :test-prefix "test_"
                                      :test-suffix "_test")
    
    ;; Clojure project detection
    (projectile-register-project-type 'clojure-lein '("project.clj")
                                      :compile "lein compile"
                                      :test "lein test"
                                      :run "lein run"
                                      :test-prefix "test_"
                                      :test-suffix "_test")
    
    (projectile-register-project-type 'clojure-deps '("deps.edn")
                                      :compile "clojure -Spath"
                                      :test "clojure -X:test"
                                      :run "clojure -M"
                                      :test-prefix "test_"
                                      :test-suffix "_test")
    
    (projectile-register-project-type 'clojure-tools '("build.edn")
                                      :compile "clojure -Spath"
                                      :test "clojure -X:test"
                                      :run "clojure -M"
                                      :test-prefix "test_"
                                      :test-suffix "_test"))

  (maybe-require-package 'ibuffer-projectile))

;; =============================================================================
;; Ibuffer Projectile Integration
;; =============================================================================

(when (maybe-require-package 'ibuffer-projectile)
  (with-eval-after-load 'ibuffer
    ;; Enable ibuffer-projectile
    (ibuffer-projectile-set-filter-groups)
    
    ;; Enhanced ibuffer-projectile configuration
    (defun ibuffer-projectile-setup ()
      "Set up ibuffer with projectile integration."
      (ibuffer-projectile-set-filter-groups)
      (unless (eq ibuffer-sorting-mode 'filename/process)
        (ibuffer-do-sort-by-filename/process)))
    
    ;; Add to ibuffer hook
    (add-hook 'ibuffer-hook 'ibuffer-projectile-setup)
    
    ;; Enhanced filter groups with projectile
    (defun ibuffer-projectile-enhanced-groups ()
      "Create enhanced filter groups with projectile integration."
      (let ((groups (ibuffer-projectile-set-filter-groups)))
        (append groups
                '(("Dired" (mode . dired-mode))
                  ("Programming" (or
                                 (mode . prog-mode)
                                 (mode . c-mode)
                                 (mode . c++-mode)
                                 (mode . java-mode)
                                 (mode . python-mode)
                                 (mode . emacs-lisp-mode)
                                 (mode . clojure-mode)
                                 (mode . javascript-mode)
                                 (mode . typescript-mode)))
                  ("Text" (or
                          (mode . text-mode)
                          (mode . markdown-mode)
                          (mode . org-mode)))
                  ("Magit" (name . "^\\*magit"))
                  ("Help" (or
                          (name . "^\\*Help")
                          (name . "^\\*Apropos")
                          (name . "^\\*info")
                          (mode . help-mode)))
                  ("Emacs" (or
                           (name . "^\\*scratch\\*$")
                           (name . "^\\*Messages\\*$")
                           (name . "^\\*Warnings\\*$")))))))
    
    ;; Enhanced ibuffer with projectile integration
    (defun ibuffer-projectile-enhanced ()
      "Open ibuffer with enhanced projectile integration."
      (interactive)
      (ibuffer)
      (ibuffer-projectile-setup))
    
    ;; Project-specific ibuffer
    (defun ibuffer-project-current ()
      "Show only buffers from the current project."
      (interactive)
      (if (projectile-project-p)
          (let ((project-root (projectile-project-root)))
            (ibuffer)
            (ibuffer-projectile-set-filter-groups)
            (message "Showing buffers for project: %s" (projectile-project-name)))
        (message "Not in a projectile project")))
    
    ;; Enhanced keybindings for ibuffer-projectile
    (define-key ibuffer-mode-map (kbd "C-c p") 'ibuffer-projectile-set-filter-groups)
    (define-key ibuffer-mode-map (kbd "C-c P") 'ibuffer-project-current)
    (define-key ibuffer-mode-map (kbd "C-c f") 'ibuffer-projectile-find-file)
    (define-key ibuffer-mode-map (kbd "C-c d") 'ibuffer-projectile-find-dir)
    (define-key ibuffer-mode-map (kbd "C-c k") 'ibuffer-projectile-kill-project-buffers)
    (define-key ibuffer-mode-map (kbd "C-c s") 'ibuffer-projectile-save-project-buffers)
    (define-key ibuffer-mode-map (kbd "C-c t") 'ibuffer-projectile-toggle-project-buffers))
  
  ;; Global keybindings for projectile ibuffer
  (global-set-key (kbd "C-c p b") 'ibuffer-projectile-enhanced)
  (global-set-key (kbd "C-c p B") 'ibuffer-project-current))

;; =============================================================================
;; Enhanced Ibuffer-Projectile Functions
;; =============================================================================

(defun ibuffer-projectile-kill-project-buffers ()
  "Kill all buffers from the current project."
  (interactive)
  (if (projectile-project-p)
      (let ((project-root (projectile-project-root))
            (project-name (projectile-project-name)))
        (when (y-or-n-p (format "Kill all buffers from project '%s'? " project-name))
          (dolist (buffer (buffer-list))
            (when (and (buffer-file-name buffer)
                       (string-prefix-p project-root (buffer-file-name buffer)))
              (kill-buffer buffer)))
          (message "Killed all buffers from project: %s" project-name)))
    (message "Not in a projectile project")))

(defun ibuffer-projectile-save-project-buffers ()
  "Save all buffers from the current project."
  (interactive)
  (if (projectile-project-p)
      (let ((project-root (projectile-project-root))
            (project-name (projectile-project-name))
            (saved-count 0))
        (dolist (buffer (buffer-list))
          (when (and (buffer-file-name buffer)
                     (string-prefix-p project-root (buffer-file-name buffer))
                     (buffer-modified-p buffer))
            (save-buffer buffer)
            (setq saved-count (1+ saved-count))))
        (message "Saved %d buffers from project: %s" saved-count project-name))
    (message "Not in a projectile project")))

(defun ibuffer-projectile-toggle-project-buffers ()
  "Toggle between showing all buffers and project buffers only."
  (interactive)
  (if (projectile-project-p)
      (let ((project-root (projectile-project-root)))
        (if (string= (car (ibuffer-current-filter-group)) (projectile-project-name))
            (progn
              (ibuffer-switch-to-saved-filter-groups "default")
              (message "Showing all buffers"))
          (progn
            (ibuffer-projectile-set-filter-groups)
            (message "Showing project buffers only"))))
    (message "Not in a projectile project")))

;; =============================================================================
;; Project Templates
;; =============================================================================

(defun create-project-readme ()
  "Create a README.md file for the current project."
  (interactive)
  (let ((readme-path (concat (projectile-project-root) "README.md"))
        (project-name (projectile-project-name)))
    (with-temp-file readme-path
      (insert (format "# %s\n\n## Description\n\n## Installation\n\n## Usage\n"
                      project-name)))
    (find-file readme-path)))

(defun create-project-gitignore ()
  "Create a .gitignore file for the current project."
  (interactive)
  (let ((gitignore-path (concat (projectile-project-root) ".gitignore")))
    (with-temp-file gitignore-path
      (insert "# Dependencies\nnode_modules/\nvenv/\n.venv/\n\n"
              "# Build\ndist/\nbuild/\n*.egg-info/\n\n"
              "# Cache\n__pycache__/\n.cache/\n.pytest_cache/\n\n"
              "# IDE\n.idea/\n.vscode/\n*.swp\n\n"
              "# OS\n.DS_Store\nThumbs.db\n"))
    (find-file gitignore-path)))

;; =============================================================================
;; Global Keybindings
;; =============================================================================

;; Global keybindings for project management
(global-set-key (kbd "C-c p r") 'create-project-readme)
(global-set-key (kbd "C-c p i") 'create-project-gitignore)

;; Enhanced fuzzy search keybindings with consult integration
(with-eval-after-load 'consult
  ;; Primary fuzzy file finder in project
  (global-set-key (kbd "C-c p f") 'consult-projectile-find-file)
  
  ;; Additional fuzzy search options
  (global-set-key (kbd "C-c p F") 'consult-find-file)
  (global-set-key (kbd "C-c p g") 'consult-ripgrep)
  
  ;; Enhanced projectile commands with fuzzy search
  (global-set-key (kbd "C-c p s") 'projectile-switch-project)
  (global-set-key (kbd "C-c p d") 'projectile-find-dir))

;; Fallback keybindings if consult is not loaded
(global-set-key (kbd "C-c p f") 'projectile-find-file)
(global-set-key (kbd "C-c p s") 'projectile-switch-project)
(global-set-key (kbd "C-c p g") 'projectile-grep)
(global-set-key (kbd "C-c p d") 'projectile-find-dir)

(provide 'init-projectile)
;;; init-projectile.el ends here
