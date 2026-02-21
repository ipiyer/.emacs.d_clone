;;; init-javascript.el --- Support for Javascript and derivatives -*- lexical-binding: t -*-
;;; Commentary:
;; This file configures JavaScript, React, and Node.js development
;; with ESLint and Prettier integration for modern web development.
;;; Code:

(maybe-require-package 'json-mode)
(maybe-require-package 'js2-mode)
(maybe-require-package 'typescript-mode)
(maybe-require-package 'prettier-js)
(maybe-require-package 'rjsx-mode)
(maybe-require-package 'add-node-modules-path)
(maybe-require-package 'js-import)
(maybe-require-package 'jest)

;;; Basic js-mode setup

(add-to-list 'auto-mode-alist '("\\.\\(js\\|es6\\)\\(\\.erb\\)?\\'" . js-mode))

(with-eval-after-load 'js
  (sanityinc/major-mode-lighter 'js-mode "JS")
  (sanityinc/major-mode-lighter 'js-jsx-mode "JSX"))

(setq-default js-indent-level 2)


;; js2-mode

;; Change some defaults: customize them to override
(setq-default js2-bounce-indent-p nil)

;; =============================================================================
;; React/JSX Support
;; =============================================================================

(with-eval-after-load 'rjsx-mode
  ;; JSX indentation
  (setq sgml-basic-offset 2)
  
  ;; Electric pairs for JSX
  (add-hook 'rjsx-mode-hook
            (lambda ()
              (setq-local electric-pair-pairs
                          (append electric-pair-pairs
                                  '((?\< . ?\>)))))))

;; Add JSX mode for .jsx files and components
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . rjsx-mode))
(add-to-list 'auto-mode-alist '("components/.*\\.js\\'" . rjsx-mode))
(with-eval-after-load 'js2-mode
  ;; Disable js2 mode's syntax error highlighting by default...
  (setq-default js2-mode-show-parse-errors nil
                js2-mode-show-strict-warnings nil)
  ;; ... but enable it if flycheck can't handle javascript
  (autoload 'flycheck-get-checker-for-buffer "flycheck")
  (defun sanityinc/enable-js2-checks-if-flycheck-inactive ()
    (unless (flycheck-get-checker-for-buffer)
      (setq-local js2-mode-show-parse-errors t)
      (setq-local js2-mode-show-strict-warnings t)
      (when (derived-mode-p 'js-mode)
        (js2-minor-mode 1))))
  (add-hook 'js-mode-hook 'sanityinc/enable-js2-checks-if-flycheck-inactive)
  (add-hook 'js2-mode-hook 'sanityinc/enable-js2-checks-if-flycheck-inactive)

  (js2-imenu-extras-setup))

(add-to-list 'interpreter-mode-alist (cons "node" 'js2-mode))

;; =============================================================================
;; Prettier Integration (Shell Command)
;; =============================================================================

(defun prettier-format-buffer ()
  "Format current buffer using prettier shell command."
  (interactive)
  (when buffer-file-name
    (shell-command (format "prettier --write %s" buffer-file-name))
    (revert-buffer t t t)))

(defun prettier-format-on-save ()
  "Format buffer on save using prettier."
  (when buffer-file-name
    (let ((original-point (point))
          (original-window-start (window-start)))
      (shell-command-on-region (point-min) (point-max)
                               (format "prettier --stdin-filepath %s" buffer-file-name)
                               (current-buffer) t)
      (goto-char original-point)
      (set-window-start (selected-window) original-window-start))))

;; =============================================================================
;; Node Modules Path
;; =============================================================================

(with-eval-after-load 'add-node-modules-path
  (add-hook 'js2-mode-hook 'add-node-modules-path)
  (add-hook 'rjsx-mode-hook 'add-node-modules-path)
  (add-hook 'typescript-mode-hook 'add-node-modules-path)
  (add-hook 'json-mode-hook 'add-node-modules-path))

;; =============================================================================
;; ESLint Integration (Shell Command)
;; =============================================================================

(defun eslint-check-buffer ()
  "Check current buffer using eslint shell command."
  (interactive)
  (when buffer-file-name
    (let ((output (shell-command-to-string (format "eslint %s" buffer-file-name))))
      (if (string-empty-p output)
          (message "ESLint: No issues found")
        (message "ESLint: %s" output)))))

(defun eslint-fix-buffer ()
  "Fix current buffer using eslint --fix shell command."
  (interactive)
  (when buffer-file-name
    (shell-command (format "eslint --fix %s" buffer-file-name))
    (revert-buffer t t t)))

;; =============================================================================
;; Import/Export Management
;; =============================================================================

(with-eval-after-load 'js-import
  (add-hook 'js2-mode-hook 'js-import-mode)
  (add-hook 'rjsx-mode-hook 'js-import-mode)
  (add-hook 'typescript-mode-hook 'js-import-mode)
  (setq js-import-sort-on-save t))

;; =============================================================================
;; Testing Support
;; =============================================================================

(with-eval-after-load 'jest
  (add-hook 'js2-mode-hook 'jest-minor-mode)
  (add-hook 'rjsx-mode-hook 'jest-minor-mode)
  (add-hook 'typescript-mode-hook 'jest-minor-mode)
  (setq jest-executable "npx")
  (setq jest-arguments '("jest")))

(with-eval-after-load 'js2-mode
  (sanityinc/major-mode-lighter 'js2-mode "JS2")
  (sanityinc/major-mode-lighter 'js2-jsx-mode "JSX2"))


(require 'derived)
(when (and (or (executable-find "rg") (executable-find "ag"))
           (maybe-require-package 'xref-js2))
  (when (executable-find "rg")
    (setq-default xref-js2-search-program 'rg))

  (defun sanityinc/enable-xref-js2 ()
    (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t))

  (let ((base-mode (if (fboundp 'js-base-mode) 'js-base-mode 'js-mode)))
    (with-eval-after-load 'js
      (add-hook (derived-mode-hook-name base-mode) 'sanityinc/enable-xref-js2)
      (define-key js-mode-map (kbd "M-.") nil)
      (when (boundp 'js-ts-mode-map)
        (define-key js-ts-mode-map (kbd "M-.") nil))))
  (with-eval-after-load 'js2-mode
    (define-key js2-mode-map (kbd "M-.") nil)))



;; =============================================================================
;; Keybindings
;; =============================================================================

;; Common JavaScript keybindings
(add-hook 'js2-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c f") 'prettier-format-buffer)
            (local-set-key (kbd "C-c l") 'eslint-check-buffer)
            (local-set-key (kbd "C-c L") 'eslint-fix-buffer)
            (local-set-key (kbd "C-c i") 'js-import-add)
            (local-set-key (kbd "C-c s") 'js-import-sort)))

(add-hook 'rjsx-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c f") 'prettier-format-buffer)
            (local-set-key (kbd "C-c l") 'eslint-check-buffer)
            (local-set-key (kbd "C-c L") 'eslint-fix-buffer)
            (local-set-key (kbd "C-c i") 'js-import-add)
            (local-set-key (kbd "C-c s") 'js-import-sort)))

(add-hook 'typescript-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c f") 'prettier-format-buffer)
            (local-set-key (kbd "C-c l") 'eslint-check-buffer)
            (local-set-key (kbd "C-c L") 'eslint-fix-buffer)
            (local-set-key (kbd "C-c i") 'js-import-add)
            (local-set-key (kbd "C-c s") 'js-import-sort)))

;; =============================================================================
;; Auto-formatting on Save
;; =============================================================================

;; Add prettier and eslint to JavaScript modes
(add-hook 'js2-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'prettier-format-on-save nil t)
            (add-hook 'before-save-hook 'eslint-check-buffer nil t)))

(add-hook 'rjsx-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'prettier-format-on-save nil t)
            (add-hook 'before-save-hook 'eslint-check-buffer nil t)))

(add-hook 'typescript-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'prettier-format-on-save nil t)
            ;(add-hook 'before-save-hook 'eslint-check-buffer nil t)
            ))

;; Run and interact with an inferior JS via js-comint.el

(when (maybe-require-package 'js-comint)
  (setq js-comint-program-command "node")

  (defvar inferior-js-minor-mode-map (make-sparse-keymap))
  (define-key inferior-js-minor-mode-map "\C-x\C-e" 'js-send-last-sexp)
  (define-key inferior-js-minor-mode-map "\C-cb" 'js-send-buffer)

  (define-minor-mode inferior-js-keys-mode
    "Bindings for communicating with an inferior js interpreter."
    :init-value nil :lighter " InfJS" :keymap inferior-js-minor-mode-map)

  (dolist (hook '(js2-mode-hook js-mode-hook))
    (add-hook hook 'inferior-js-keys-mode)))


(provide 'init-javascript)
;;; init-javascript.el ends here
