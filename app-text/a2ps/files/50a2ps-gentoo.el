
;;; a2ps site-lisp configuration

(add-to-list 'load-path "@SITELISP@")
(autoload 'a2ps-mode "a2ps" nil t)
(autoload 'a2ps-buffer "a2ps-print" nil t)
(autoload 'a2ps-region "a2ps-print" nil t)
(add-to-list 'auto-mode-alist '("\\.a2ps\\'" . a2ps-mode))
