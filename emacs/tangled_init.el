(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))
(add-hook 'after-init-hook #'(lambda ()
                               ;; restore after startup
                               (setq gc-cons-threshold 800000)))

(load-theme 'leuven)

(if (fboundp 'menu-bar-mode)
    (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))

(setq-default cursor-type 'bar)           ; Line-style cursor similar to other text editors
(setq inhibit-startup-screen t)           ; Disable startup screen
(setq initial-scratch-message "")         ; Make *scratch* buffer blank
(setq-default frame-title-format '("%b")) ; Make window title the buffer name
(setq ring-bell-function 'ignore)         ; Disable bell sound
(fset 'yes-or-no-p 'y-or-n-p)             ; y-or-n-p makes answering questions faster
(show-paren-mode 1)                       ; Show closing parens by default
(setq linum-format "%4d ")                ; Line number format
(delete-selection-mode 1)                 ; Selected text will be overwritten when you start typing
(global-auto-revert-mode t)               ; Auto-update buffer if file has changed on disk

(add-hook 'prog-mode-hook
          (if (and (fboundp 'display-line-numbers-mode) (display-graphic-p))
              #'display-line-numbers-mode
            #'linum-mode))

(column-number-mode)

(setq vc-follow-symlinks t)

(global-auto-revert-mode t)

(setq custom-file "~/.emacs.d/custom.el")
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
;;; Load custom file. Don't hide errors. Hide success message
(load custom-file nil t)

(defconst emacs-tmp-dir (expand-file-name (format "emacs%d" (user-uid)) temporary-file-directory))
(setq
 backup-by-copying t                                        ; Avoid symlinks
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t
 auto-save-list-file-prefix emacs-tmp-dir
 auto-save-file-name-transforms `((".*" ,emacs-tmp-dir t))  ; Change autosave dir to tmp
 backup-directory-alist `((".*" . ,emacs-tmp-dir)))

;;; Lockfiles unfortunately cause more pain than benefit
(setq create-lockfiles nil)

(setq-default tab-width 4
              indent-tabs-mode nil)
(setq whitespace-style '(trailing tabs tab-mark))
(global-whitespace-mode t)

(global-set-key [mouse-3] 'mouse-popup-menubar-stuff)          ; Gives right-click a context menu
(global-set-key (kbd "C->") 'indent-rigidly-right-to-tab-stop) ; Indent selection by one tab length
(global-set-key (kbd "C-<") 'indent-rigidly-left-to-tab-stop)  ; De-indent selection by one tab length

(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;;; Setup package.el
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(unless package--initialized (package-initialize))

;;; Setup use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

(defun reload-config ()
  (interactive)
  (load-file (concat user-emacs-directory "init.el")))

(setq org-directory "~/Documents/Org")

(defun custom/org-path (p)
  "Create absolute path for a file located in org-directory"
  (concat org-directory "/" p))

;; We need the seq package for some sequence manipulations bellow.
(require 'seq)

;; The full list of files that might be present in org-directory.
(setq custom/org-files-all
      '("inbox.org"
        "projects.org"
        "work_inbox.org"
        "work_projects.org"))

(setq custom/org-files-available
      (seq-filter 'file-exists-p
                  (seq-map (lambda (x) (expand-file-name (concat org-directory "/" x)))
                           custom/org-files-all)))

;; Check if we are at work or at home (i.e., presence of a "work_inbox.org" file).
(setq custom/org-at-work
      (file-exists-p (custom/org-path "work_inbox.org")))

;; Build path to special org-mode files.
(setq custom/org-inbox
      (custom/org-path (if custom/org-at-work "work_inbox.org" "inbox.org")))
(setq custom/org-projects
      (custom/org-path (if custom/org-at-work "work_projects.org" "projects.org")))

(setq org-agenda-files custom/org-files-available)

;; We don't want org-mode to insert manual indentation.
(setq org-adapt-indentation nil)

;; Show only overview when opening new files
(setq org-startup-folded t)

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n!)" "HOLD(h!@)" "MAYBE(m!)" "|" "DONE(d!)" "CANCELLED(c@)")))
(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "red" :weight bold))
        ("NEXT" . (:foreground "purple" :weight bold))
        ("HOLD" . (:foreground "blue" :weight bold))
        ("MAYBE" . (:foreground "dark orange" :weight bold))
        ("DONE" . (:foreground "forest green" :weight bold))
        ("CANCELLED" . (:foreground "red" :weight bold))))

(setq org-tag-alist
      '((:startgroup . nil)
        ("@work" . ?w) ("@home" . ?h)
        (:endgroup . nil)
        ("inbox" . ?b)
        ;; Content type
        ("tip" . ?t)
        ("review" . ?r)
        ("note" . ?n)
        ("idea" . ?i)
        ("project" . ?p)
        ;; Topic
        ("desktop" . ?d)
        ("hot". ?o)))

(setq org-capture-templates
      `(
        ("t" "Todo" entry (file ,custom/org-inbox)
         "* TODO %?
:PROPERTIES:
:CREATED:  %U
:END:" :prepend t)))

(setq org-refile-targets
    `((,custom/org-projects :regexp . "\\(?:Tasks?\\)")
      ;; Experimental, see if the tag approach is ok
      ;; (,custom/org-projects :maxlevel . 2))
    ))
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)

(setq org-global-properties
    '(("Effort_ALL" . "0 0:05 0:10 0:15 0:30 0:45 1:00 2:00 4:00")))
(setq org-log-done 'time)
(setq org-log-into-drawer t)

(org-babel-do-load-languages
 'org-babel-load-languages '((emacs-lisp . t)
                             (shell . t)
                             (C . t)
                             (python . t)
                             (scheme . t)))

;; Don't prompt for evaluating src blocks
(setq org-confirm-babel-evaluate nil)

(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)

(use-package undo-tree
  :init (global-undo-tree-mode))

(use-package helm)
(require 'helm-config)
(helm-mode 1)

(define-key global-map (kbd "M-x") 'helm-M-x)
(define-key global-map (kbd "C-x C-f") 'helm-find-files)
(define-key global-map (kbd "M-y") 'helm-show-kill-ring)
(define-key global-map (kbd "C-x b") 'helm-mini)

(use-package org-tree-slide)

(define-key org-tree-slide-mode-map
  (kbd "<f9>") 'org-tree-slide-move-previous-tree)
(define-key org-tree-slide-mode-map
  (kbd "<f10>") 'org-tree-slide-move-next-tree)

(use-package org-ref
  ;; Optional: set a path to a default bibtex file.
  ;; :custom
  ;; (org-ref-default-bibliography (custom/org-path "zotero.bib"))
  )

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename (custom/org-path "notes")))
  :config
  (org-roam-setup))

(global-set-key (kbd "C-c n f") 'org-roam-node-find)
(global-set-key (kbd "C-c n i") 'org-roam-node-insert)
(global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle)

(use-package magit
  :bind (("C-x g" . magit-status)))

(use-package evil
  :ensure t
  :config
  (evil-mode 1))
(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))
(use-package org-evil
  :ensure t)

(evil-define-key '(normal visual motion) 'global
  (kbd "t") 'evil-backward-char
  (kbd "s") 'evil-next-line
  (kbd "r") 'evil-previous-line
  (kbd "n") 'evil-forward-char)
