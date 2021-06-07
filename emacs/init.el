;; Needs to be configured before the sanemacs import
(load-theme 'tsdh-light)

;; Use the sanemacs defaults (https://sanemacs.com/)
;;
;; Those are very minimalistic defaults, the file is heavily commented
;; and worth a read.
;;
;; Get the file with:
;;     curl https://sanemacs.com/sanemacs.el > ~/.emacs.d/sanemacs.el
(load "~/.emacs.d/sanemacs.el" nil t)

;; 0. Extra dependencies
(require 'seq)


;; 1. General Settings

;; Automatic reload of files if modified
(global-auto-revert-mode t)

;; Always follow symlinks
(setq vc-follow-symlinks t)

;; Increasing font-size quickly
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; Whitespace configuration: no tabs (=> 4 spaces), highlight trailing.
(setq-default tab-width 4
              indent-tabs-mode nil)
(setq whitespace-style '(trailing tabs tab-mark))
(global-whitespace-mode t)

;; Enable helm for incremental completion.
;;
;; FIXME: I am very new to helm, need to see if it is the correct way
;; to configure it...
(use-package helm)
(require 'helm-config)
(helm-mode 1)


;; 2. Org-mode customizations

;; Root of org-related stuff (must be the same on all my computers).
(setq org-directory "~/Documents/Org")
(defun custom/org-path (p)
  "Create absolute path for a file located in org-directory"
  (concat org-directory "/" p))

(setq custom/org-files-all
      '("inbox.org"
        "projects.org"
        "work_inbox.org"
        "work_projects.org"))
(setq custom/org-files-available
      (seq-filter 'file-exists-p
                  (seq-map (lambda (x) (expand-file-name (concat org-directory "/" x)))
                           custom/org-files-all)))

;; Check if I am at work. Several files change depending on where I am.
(setq custom/org-at-work
      (file-exists-p (custom/org-path "work_inbox.org")))

;; Generic path
(setq custom/org-inbox
      (custom/org-path (if custom/org-at-work "work_inbox.org" "inbox.org")))
(setq custom/org-projects
      (custom/org-path (if custom/org-at-work "work_projects.org" "projects.org")))

;; This key binding is not used on vanilla orgmode
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)

;; We don't want org-mode to insert manual indentation.
(setq org-adapt-indentation nil)

;; Show only overview when opening new files
(setq org-startup-folded t)

;; Optional: add visual line wrapping. However, this doesn't play well
;; with 1 line/sentence writing style... I opted for "M-q all the time"!

;; (add-hook 'org-mode-hook 'visual-line-mode)

;; Use org-ref for quick referencing.
(use-package org-ref
    :custom
    (org-ref-default-bibliography (custom/org-path "zotero.bib")))
;; Light alternative to org-ref, but I don't know how to install it :(
;; (require 'ox-bibtex)

;; Zettlekasen-style notes with org-mode.
;; WARN: This package is currently under test
(use-package org-roam
      :ensure t
      :hook
      (after-init . org-roam-mode)
      :custom
      (org-roam-directory (file-truename (custom/org-path "notes")))
      :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-find-file)
               ("C-c n g" . org-roam-graph))
              :map org-mode-map
              (("C-c n i" . org-roam-insert))
              (("C-c n I" . org-roam-insert-immediate))))
(add-hook 'after-init-hook 'org-roam-mode)

;; Experimental, should I keep this??
(require 'ox-latex)
(add-to-list 'org-latex-classes
             '("koma-article"
               "\\documentclass{scrartcl}
                \\usepackage{microtype}
                \\usepackage{libertine}
                % \\usepackage{tgpagella}
                % \\linespacing{1.05}
                % \\usepackage[scale=.9]{tgheros}
                % \\usepackage{tgcursor}
                \\usepackage{paralist}"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

(setq org-global-properties
      '(("Effort_ALL" . "0 0:05 0:10 0:15 0:30 0:45 1:00 2:00 4:00")))
;; Set global Column View format
(setq org-columns-default-format '"%38ITEM(Details) %TAGS(Context) %7TODO(To Do) %5Effort(Time){:} %6CLOCKSUM(Clock)")
(setq org-log-done 'time)

;; Keywords, to support GTD-style task managment.
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

(setq org-log-into-drawer t)
(setq org-agenda-files custom/org-files-available)
;; TODO: update with correct files? maybe add a regexp to keep
;; interesting targets only...
(setq org-refile-targets
      `((,custom/org-projects :regexp . "\\(?:Tasks?\\)")
        ;; Experimental, see if the tag approach is ok
        ;; (,custom/org-projects :maxlevel . 2))
      ))
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)

;; Our capture templates all have a destination file. We do not need a fallback location.
;; (setq org-default-notes-file (concat org-directory "/main.org"))

(setq org-capture-templates
      `(
        ("t" "Todo" entry (file ,custom/org-inbox)
         "* TODO %?
:PROPERTIES:
:CREATED:  %U
:END:" :prepend t)))

(setq org-agenda-custom-commands
      '(("g" "Get Things Done (GTD)"
         ((agenda ""
                  ((org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'deadline))
                   (org-deadline-warning-days 0)))
          (todo "NEXT"
                ((org-agenda-skip-function
                  '(org-agenda-skip-entry-if 'deadline))
                 (org-agenda-prefix-format "  %i %-12:c [%e] ")
                 (org-agenda-overriding-header "\nTasks\n")))
          (agenda nil
                  ((org-agenda-entry-types '(:deadline))
                   (org-agenda-format-date "")
                   (org-deadline-warning-days 7)
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'notregexp "\\* NEXT"))
                   (org-agenda-overriding-header "\nDeadlines")))
          (tags-todo "inbox"
                     ((org-agenda-prefix-format "  %?-12t% s")
                      (org-agenda-overriding-header "\nInbox\n")))
          (tags "CLOSED>=\"<today>\""
                ((org-agenda-overriding-header "\nCompleted today\n")))))))

(org-babel-do-load-languages
   'org-babel-load-languages '((C . t)
                               (python . t)))

;; Don't prompt for evaluating src blocks
(setq org-confirm-babel-evaluate nil)

;; Latexmk is a more robust option for building PDF (especially with references).
;; It handles the repeated calls to pdflatex and friends for you.
(setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdf %f"))
