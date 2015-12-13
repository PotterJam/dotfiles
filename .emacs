(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" .
"http://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
(package-initialize)

(require 'evil)
(evil-mode t)
(tool-bar-mode -1)
(menu-bar-mode -1)


(set-default-font "Terminus")

(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.

Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; Make sure to have downloaded archive description.
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

;; Activate installed packages
(package-initialize)

;; Assuming you wish to install "iedit" and "magit"
(ensure-package-installed 'quickrun 'expand-region 'ace-jump-mode 'magit 'relative-line-numbers 'dtrt-indent 'fill-column-indicator 'evil-leader 'flx-ido 'projectile 'helm-projectile 'yasnippet 'auto-complete 'evil 'helm 'powerline)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (sanityinc-tomorrow-night)))
 '(custom-safe-themes
   (quote
    ("06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" default)))
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'quickrun)

;;; smooth scrolling
(setq scroll-margin 5
      scroll-conservatively 9999
      scroll-step 1)

;;; turn on powerline
(require 'powerline)
(powerline-center-evil-theme)

;;; set up relative line numbers
(add-hook 'prog-mode-hook 'relative-line-numbers-mode t)
(add-hook 'prog-mode-hook 'line-number-mode t)
(add-hook 'prog-mode-hook 'column-number-mode t)

;;; set theme as tomorrow
(require 'color-theme-sanityinc-tomorrow)

(load "auctex.el" nil t t)
(require 'tex-mik)

;;; yasnippet
(require 'yasnippet)
(yas-global-mode 1)

;;; auto complete mod
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)

;;; set tabbing to be correct
(setq-default tab-width 4 indent-tabs-mode nil)

;;; set tabbing to be correct for prog
(setq-default c-basic-offset 4 c-default-style "bsd")

(dtrt-indent-mode 1)

;;; set the trigger key so that it can work together with yasnippet on tab key,
;;; if the word exists in yasnippet, pressing tab will cause yasnippet to
;;; activate, otherwise, autocomplete will.
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")

;;; enable projectile globally
(projectile-global-mode)

;;; auto indent with return key
(define-key global-map (kbd "RET") 'newline-and-indent)

;;; org mode...
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;;; set initial scratch state as org mode
(setq initial-major-mode 'org-mode)

;;; set helm as m-x
(global-set-key (kbd "M-x") 'helm-M-x)

;; esc quits
(defun minibuffer-keyboard-quit ()
    "Abort recursive edit.
  In Delete Selection mode, if the mark is active, just deactivate it;
  then it takes a second \\[keyboard-quit] to abort the minibuffer."
    (interactive)
	  (if (and delete-selection-mode transient-mark-mode mark-active)
		      (setq deactivate-mark  t)
			      (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
				      (abort-recursive-edit)))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(global-set-key [escape] 'evil-exit-emacs-state)

;;; j and k for going over wrapped lines fix
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

;;; configure fill column, auto line breaking and column limit marks
(add-hook 'text-mode-hook (lambda ()
(turn-on-auto-fill)
(fci-mode)
(set-fill-column 82)))

(add-hook 'markdown-mode-hook (lambda ()
(turn-on-auto-fill)
(fci-mode)
(set-fill-column 82)))

;;; To set the non-auto-line limit for Python a C-mode (and D) to 94:
(add-hook 'python-mode-hook (lambda ()
(fci-mode)
(set-fill-column 94)))

(add-hook 'c-mode-hook (lambda ()
(fci-mode)
(set-fill-column 94)))

(add-hook 'd-mode-hook (lambda ()
(fci-mode)
(set-fill-column 94)))


;;; set up leader key (,)
(global-evil-leader-mode)

(evil-leader/set-leader "<SPC>")

;;; set up leader shortcuts
(eval-after-load "helm"
		(evil-leader/set-key
			"\\" 'shell-command
            "s" 'ace-jump-char-mode
            "e" 'ace-jump-word-mode
            "i" 'ace-jump-line-mode
			"l" 'helm-for-files
			"K" 'helm-show-kill-ring
			"t" 'helm-top
			"m" 'helm-man-woman
			"/" 'helm-occur
			"j" 'helm-M-x
			"f" 'helm-find-files
            "o" 'other-window
			"b" 'helm-buffers-list
			"h" 'helm-projectile-find-file
			"r" 'helm-recentf
			"H" 'helm-projectile))
	(eval-after-load "helm-ag"
		(evil-leader/set-key
			"a" 'helm-projectile-ag))
	(eval-after-load "expand-region"
		(progn
			(setq expand-region-contract-fast-key "z")
			(evil-leader/set-key "xx" 'er/expand-region)))
	(eval-after-load "magit"
		(evil-leader/set-key "g" 'magit-status))
	(eval-after-load "quickrun"
		(evil-leader/set-key "q" 'quickrun))
	(eval-after-load "git-gutter-mode"
		(evil-leader/set-key
            "y" 'git-gutter:stage-hunk
			"n" 'git-gutter:next-hunk
			"p" 'git-gutter:previous-hunk))
	(evil-leader/set-key
		"k" 'kill-buffer
		"d" 'dired
		"." 'repeat
		"0" 'delete-window
		"u" 'delete-other-windows
		"2" 'split-window-below
		"3" 'split-window-right)

;;; show matching paren
(show-paren-mode t)
