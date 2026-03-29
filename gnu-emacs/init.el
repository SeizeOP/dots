; package management setup
; package management setup
;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq inhibit-startup-message 1) ; disable splash screen
(setq visual-bell 1) ; flash when bell rings
(tool-bar-mode -1)

(if (display-graphic-p)
    (tab-bar-mode 1)
  (tab-bar-mode -1))
(if (display-graphic-p)
    (menu-bar-mode 1)
  (menu-bar-mode -1))
(if (display-graphic-p)
    (scroll-bar-mode 1)
  (scroll-bar-mode -1))
(if (display-graphic-p)
    (tab-bar-mode 1)
  (tab-bar-mode -1))
  
(use-package treemacs
  :ensure t)  
  
(add-hook 'treemacs-mode
  	  (display-line-numbers-mode -1))

(eval-after-load 'treemacs-mode 
  '(define-key treemacs-mode-map (kbd "j") 'treemacs-next-line))
(eval-after-load 'treemacs-mode
  '(define-key treemacs-mode-map (kbd "k") 'treemacs-previous-line))

;; Save what you enter into minibuffer prompts
(setq history-length 25)
(savehist-mode 1)


; NOTE: Pressing 'F10' while the menu bar is disabled will bring up a menu next to the mouse with all the same options as the menu bar. When the menue bar is enabled, pressing 'F10' brings focus to the menu bar instead.

; NOTE: C-z conflicts with mode switch between emacs and evil mdes. use 'u' instead.
; for redo use 'C-r'
   
;(global-set-key (kbd "C-z") 'evil-undo)
;(global-set-key (kbd "C-y") 'evil-redo)
(defun comment-dwim-line (&optional arg)
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \\t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))

(global-set-key (kbd "M-;") 'comment-dwim-line)   

(defun my-auto-comment-region ()
    "Comment the current region, extending to the end of each line."
    (interactive)
    (let* ((start (region-beginning))
           (end   (region-end))
           (end-line (save-excursion
                       (goto-char end)
                       (line-end-position))))
      (comment-region start end-line)))

; Toggle the Emacs menu bar with the 'F11' key. By default the menu bar is enabled.
; Note: this overrides the default behavior of 'F11' which is to maximize the emacs window.
(defun toggle-menu-bar ()
  "Toggle the menu bar display."
  (interactive)
  (menu-bar-mode (if menu-bar-mode -1 1)))


;; BUFFER MOVE
(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      (set-window-buffer (selected-window) (window-buffer other-win))
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      (set-window-buffer (selected-window) (window-buffer other-win))
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      (set-window-buffer (selected-window) (window-buffer other-win))
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      (set-window-buffer (selected-window) (window-buffer other-win))
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;; PANDOC EXPORT
(defun export-with-pandoc ()
     	    (interactive) 
     	    (when buffer-file-name 
     	      (shell-command (concat "pandoc -f markdown -t pdf -o ~/Documents/output.pdf " (shell-quote-argument buffer-file-name)))))

(defun toggle-dialog-box ()
  "Toggle the use of GUI dialog boxes in Emacs."
  (interactive)
  (setq use-dialog-box (not use-dialog-box))
  (message "GUI dialogs are now %s" 
           (if use-dialog-box "enabled" "disabled")))
; list recently editted files
(setq recentf-mode 1)
; enable line numbers
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(column-number-mode)

;; Disable line numbers for some modes
(dolist (mode '(term-mode-hook
		treemacs-mode-hook
		vterm-mode-hook
		eat-mode-hook
                eshell-mode-hook
                shell-mode-hook
		org-side-tree-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

; set theme
;(load-theme 'modus-vivendi t)

;; Remember and restore the last cursor location of opened files
(save-place-mode 1)
;; Don't pop up UI dialogs when prompting
(setq use-dialog-box nil)
;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

;; Move customization variables to a separate file and load it
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0))

(use-package general
  :config
  (general-evil-setup 1)

  (general-create-definer hd/leader-keys
			  :states '(normal insert visual emacs)
			  :keymaps 'override
			  :prefix "SPC"
			  :global-prefix "C-SPC")
  (hd/leader-keys
    "b" '(:ignore t :wk "buffer")
    "b b" '(switch-to-buffer :wk "Switch buffer")
    "b k" '(kill-current-buffer :wk "Kill this buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b R" '(revert-buffer-quick :wk "Reload buffer WITHOUT conformation")
    "b s" '(scratch-buffer :wk "Scratch buffer"))
  (hd/leader-keys
    "c" '(:ignore t :wk "comment")
    "c l" '(comment-dwim-line :wk "comment lines")
    "c r" '(my-auto-comment-region :wk "comment out selected region")
    "c d" '(uncomment-region :wk "uncomment selected region")
    "c u" '(insert-char :wk "Select and insert Unicode characters"))
  (hd/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "dired"))
    (hd/leader-keys
    "e" '(:ignore t :wk "Eshell/Evaluate")
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate elisp expression")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    "e s" '(eshell :which-key "Eshell"))
  (hd/leader-keys
    "." '(find-file :wk "Find file")
    "f" '(:ignore t :wk "Find")
    "f c" '((lambda () (interactive) (find-file "~/dotfiles/emacs/README.org")) :wk "Edit Emacs config")
    "f f" '(query-replace-regexp :wk "Query Replace (regexp)")
    "f h" '((lambda () (interactive) (find-file "~/dotfiles/hypr/hyprland.org")) :wk "Edit Hyprland config")
    "f u" '(sudo-edit-find-file :wk "Sudo find file")
    "f U" '(sudo-edit :wk "Sudo edit file")
    "f n" '((lambda () (interactive) (find-file "~/dotfiles/niri/niri.org")) :wk "Edit Niri config")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f s" '((lambda () (interactive) (find-file "~/scripts/bash/setup.org")) :wk "Edit setup script")
    "f w" '((lambda () (interactive) (find-file "~/dotfiles/waybar/waybar.org")) :wk "Edit Waybar config"))
(hd/leader-keys
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe-variable")
    ;; "h r r" '(reload-init-file :wk "Reload emacs config"))
    "h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config"))
  (hd/leader-keys
    "m e" '(org-export-dispatch :wk "Export dispatcher for orgmode.")
    "m p" '(export-with-pandoc :wk "Export Markdown directly to PDF")
    "m q" '(qrencode-export-buffer-to-file :wk "Export qrcode buffers to a file"))
  (hd/leader-keys
    "n" '(:ignore t :wk "Org-roam/Notes")
    "n c" '(org-roam-node-create :wk "Create Note")
    "n f" '(org-roam-node-find :wk "Find Note")
    "n d" '(org-roam-dailies-capture-today :wk "Create Today's Note")
    "n g" '(org-roam-ui-open :wk "Open Org-roam UI")
    "n i" '(org-roam-node-insert :wk "Insert Note")
    "n t" '(org-roam-dailies-capture-tomorrow :wk "Create Tomorrow's Note")
    "n u" '(org-roam-ui-mode :wk "Toggle Org-roam UI Mode")
    "n y" '(org-roam-dailies-capture-yesterday :wk "Create Yesterday's Note"))
  (hd/leader-keys
    "o" '(:ignore t :wk "Open")
    "o b" '(browse-url-of-buffer :wk "Open the current buffer in the XDG default browser")
    "o c" '(calendar :wk "Open Calendar")  
    "o e" '(eshell :wk "Open Eshell")  
    "o f" '(make-frame-command :wk "Open new window (Frame)")  
    "o l" '(browse-url-xdg-open :wk "Open a URL in the XDG default browser")
    "o s" '(org-side-tree :wk "Org Side-Tree")
    ;; "o t" '(vterm-toggle :wk "Open Vterm")
    "o t" '(eat :wk "Open Eat")
    "o q" '(qrencode-url-at-point :wk "Generate a qrcode from UR under cursor"))
  (hd/leader-keys
    "q" '(:ignore t :wk "Quit/Exit options")
    "q q" '(save-buffers-kill-emacs :wk "Save buffers and kill Emacs")
    "q r" '(restart-emacs :wk "Restart Emacs")) 
 (hd/leader-keys
    "s" '(:ignore t :wk "Saving")
    "s b" '(save-buffer :wk "Save current buffer")
    "s B" '(save-some-buffers :wk "Prompt & Save all open buffers")
    "s a" '(auto-save-mode :wk "Save session"))
 (hd/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t c" '(org-toggle-checkbox :wk "Toggle Orgmode checkboxes")
    "t d" '(toggle-dialog-box :wk "Toggle GUI dialogs")
    "t i" '(org-toggle-inline-images :wk "Toggle Orgmode inline images")
    "t l" '(org-toggle-link-display :wk "Toggle Orgmode link display")
    "t L" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t r" '(read-only-mode :wk "Toggle Read Only mode")
    "t t" '(visual-line-mode :wk "Toggle visual line mode")
    ;; "t v" '(vterm-toggle :wk "Toggle vterm")
    "t m" '(treemacs :wk "Toggle treemacs")
    "t s" '(org-side-tree-toggle :wk "Toggle Org Side tree"))
  (hd/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Window motions
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right")))
(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-integration t)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-beow t)
  (setq evil-undo-system 'undo-redo)
  (evil-mode 1))
(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last ivy-based completion.
  (("C-C C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
   :custom
   (setq ivy-use-virtual-buffers t)
   (setq ivy-count-format "(%d/%d) ")
   (setq enable-recursive-minibuffers t)
   :config
   (ivy-mode 1))
(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
   :config
   (ivy-set-display-transformer 'ivy-switch-buffer
    'ivy-rich-switch-buffer-transformer)) 
(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package counsel 
  :after ivy
  :config (counsel-mode))

;; Org-appear
(setq org-hide-emphasis-markers 1)
(use-package org-appear) 
(add-hook 'org-mode-hook 'org-appear-mode)

(setq org-image-actual-width nil)

;; like org apear for subscripts (using '_') and superscripts (using '^')
(setq org-pretty-entities 1)

;; better list bullets
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
; CUA settings
; C-c and C-x are predefined
(cua-mode 1)
(global-set-key (kbd "C-a") 'mark-whole-buffer)
(require 'evil)
(evil-define-key 'normal global-map (kbd "C-f") 'evil-search-forward)   
(evil-define-key 'normal global-map (kbd "C-y") 'evil-redo)   

;; Disable Evil mode for select modes
(evil-set-initial-state 'eat-mode 'emacs)
(evil-set-initial-state 'eshell-mode 'emacs)
(evil-set-initial-state 'treemacs-mode 'emacs)

(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-<wheel-up>") 'text-scale-increase)
(global-set-key (kbd "C-<wheel-down>") 'text-scale-decrease)
(global-set-key (kbd "<f11>") 'toggle-menu-bar)

; Version Control
(setq vc-follow-symlinks 1)
(setq vc-handled-backends '(Git))

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;; MARKDOWN
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
         ("C-c C-e" . markdown-do)))

(setq markdown-split-window-direction 'right)
(setq markdown-live-preview-delete-export 'delete-on-export)

;; ORG
(require 'org-tempo)
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

  (use-package org-roam 
    :ensure t
    :custom
    (org-roam-directory (file-truename "~/Documents/org/org-roam/"))
    :bind (("C-c n l" . org-roam-buffer-toggle)
           ("C-c n f" . org-roam-node-find)
           ("C-c n i" . org-roam-node-insert)
           ("C-c n d" . org-roam-dailies-capture-today)
           ("C-c n y" . org-roam-dailies-capture-yesterday)
           ("C-c n t" . org-roam-dailies-capture-tomorrow)
           ;; Org-roam UI binds
           ("C-c n u" . org-roam-ui-mode)
           ("C-c n g" . org-roam-ui-open))
    :config
    (org-roam-setup))

(use-package org-roam-ui
  :ensure t
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(use-package org-side-tree
  :ensure t)

;; (with-eval-after-load 'ol
;;   (org-link-set-parameters "tel"
;; 			   :export (lambda (path desc backend)
;; 				     (cond
;; 				      ((eq backend 'html)
;; 				       (format "<a href=\"tel:%s\">%s</a>" path (or desc path)))
;; 				      ((eq backend 'odt)
;; 				       (format "<text:a xlink:type=\"simple\" xlink:href=\"tel:%s\">%s</text:a>" path (or desc path))))))

(use-package yafolding
    :ensure t
    :hook org-mode prog-mode shell-script-mode)

;; (defun efs/org-mode-visual-fill ()
;;   (setq visual-fill-column-width 100
;;         visual-fill-column-center-text t)
;;   (visual-fill-column-mode 1))

;; (use-package visual-fill-column
;;   :hook (org-mode . efs/org-mode-visual-fill))

;; ; set theme
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-dracula t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-dracula") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

; helm is a dependency of doom-modeline
(use-package helm
  :ensure t)		      
;(package-vc-install '(helm-ag :url "https://github.com/emacsattic/helm-ag"))
(use-package doom-modeline 
  :ensure t
  :init
  (doom-modeline-mode 1))

  (setq doom-modeline-height 40)
  (setq doom-modeline-bar-width 4)
  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-major-mode-color-icon t)
  (setq doom-modeline-enable-word-count t)
  (setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))

(use-package time
    :ensure nil
    :config
    (display-time-mode 1)
    :custom
    (display-time-default-load-average nil)
    (display-time-24hr-format t))

(use-package nyan-mode
  :init
  (if (display-graphic-p)
      (nyan-mode 1)
    (nyan-mode -1)))
; customize nyan-mode progress-bar background
; Eshell Setup
;; (setq display-buffer-alist
      ;; '(("\\`\\*e?shell" display-buffer-in-side-window (side . bottom))))
;; (setq display-buffer-alist
      ;; '(("\\`\\*eat" display-buffer-in-side-window (side . bottom))))
(add-to-list 'display-buffer-alist
             '("\\`\\*eshell\\*\\(?:<[[:digit:]]+>\\)?\\'"
               (display-buffer-in-side-window (side . bottom))))
(add-to-list 'display-buffer-alist
             '("\\`\\*eat\\*\\(?:<[[:digit:]]+>\\)?\\'"
               (display-buffer-in-side-window (side . bottom))))
(add-to-list 'display-buffer-alist
             '("\\`\\*vterm\\*\\(?:<[[:digit:]]+>\\)?\\'"
               (display-buffer-in-side-window (side . bottom))))

(require 'general)
(require 'eshell)
; NOTE: holding C-c also works to send 'eshell-interrupt-process'
(general-def :keymaps 'eshell-mode-map :states '(insert) "C-c RET" 'eshell-kill-process)

(use-package eshell-syntax-highlighting
    :after eshell-mode
    :config
    (eshell-syntax-highlighting-global-mode 1))

(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
        eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
        eshell-history-size 5000
        eshell-buffer-maximum-lines 5000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package eat)
(add-to-list 'exec-path "/home/linuxbrew/.linuxbrew/bin/")
(add-to-list 'exec-path "/home/linuxbrew/.linuxbrew/sbin/")

; shell REPL
; Source - https://stackoverflow.com/a/25496288
; Posted by thiagowfx
; Retrieved 2026-03-17, License - CC BY-SA 3.0
(define-key comint-mode-map (kbd "<up>") 'comint-previous-input)
(define-key comint-mode-map (kbd "<down>") 'comint-next-input)
