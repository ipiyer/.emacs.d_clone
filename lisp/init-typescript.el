;;; init-typescript.el --- TypeScript support -*- lexical-binding: t; -*-

;;; Commentary:
;; 
;; This file provides support for TypeScript, integrating with `typescript-mode`
;; and `eglot` for a modern development experience.
;;
;;; Code:

(when (maybe-require-package 'typescript-mode)
  (add-to-list 'auto-mode-alist '("\.ts\'" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\.tsx\'" . typescript-mode))

  (setq-default typescript-indent-level 2)

  (add-hook 'typescript-mode-hook
            (lambda () 
              (add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode)
              (eglot-ensure)))

  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs '(typescript-mode . ("typescript-language-server" "--stdio")))))

(provide 'init-typescript)
;;; init-typescript.el ends here
