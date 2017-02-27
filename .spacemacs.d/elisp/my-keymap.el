(defun my-keymap/evil-c$ ()
  (interactive)
  (let ((begin (progn (current-column) (point)))
        (end (progn (end-of-line) (point))))
    (evil-change begin end)))

(defun my-keymap/evil-insert-c-u ()
  (interactive)
  (let ((begin (progn (current-column) (point)))
        (end (progn (evil-first-non-blank) (point))))
    (evil-change begin end)))

(setq evil-want-C-i-jump t)

(define-key evil-insert-state-map "\M-r" 'quickrun)
(define-key evil-normal-state-map "\M-r" 'quickrun)
(define-key evil-insert-state-map "\M-v" 'helm-imenu)
(define-key evil-normal-state-map "\M-v" 'helm-imenu)
(define-key evil-insert-state-map "\M-t" 'neotree-toggle)
(define-key evil-normal-state-map "\M-t" 'neotree-toggle)

(define-key evil-normal-state-map "\M-f" 'avy-migemo-goto-char-2)
(define-key evil-normal-state-map "\C-h" 'evil-backward-char)
(define-key evil-normal-state-map "\C-k" 'my-keymap/evil-c$)
(define-key evil-normal-state-map "\C-n" 'tabbar-forward-tab)
(define-key evil-normal-state-map "\C-p" 'tabbar-backward-tab)
(define-key evil-normal-state-map (kbd "\\") 'ignore)
(define-key evil-normal-state-map "\M-s" 'swiper)
(define-key evil-normal-state-map "\C-[" 'save-buffer)
(define-key evil-normal-state-map [escape] 'save-buffer)

(define-key evil-insert-state-map "\C-a" 'evil-insert-line)
(define-key evil-insert-state-map "\C-e" 'move-end-of-line)
(define-key evil-insert-state-map "\C-d" 'evil-delete-char)
(define-key evil-insert-state-map "\C-h" 'delete-backward-char)
(define-key evil-insert-state-map "\C-i" 'hippie-expand)
(define-key evil-insert-state-map "\C-j" 'newline-and-indent)
(define-key evil-insert-state-map "\C-u" 'my-keymap/evil-insert-c-u)
(define-key evil-insert-state-map "\C-n" '(lambda () (interactive) (company-select-next) (company-select-previous)))
(define-key evil-insert-state-map "\C-p" '(lambda () (interactive) (company-select-previous) (company-select-next)))

(add-hook 'company-mode-hook
          '(lambda ()
             (define-key company-active-map (kbd "<tab>") 'hippie-expand)
             (define-key company-active-map (kbd "C-h") 'delete-backward-char)
             (define-key company-active-map (kbd "C-i") 'hippie-expand)
             (define-key company-active-map (kbd "C-j") 'company-complete-selection)
             (define-key company-active-map (kbd "C-m") 'company-complete-selection)
             (define-key company-active-map (kbd "C-n") 'company-select-next)
             (define-key company-active-map (kbd "C-p") 'company-select-previous)
             (define-key company-active-map (kbd "C-q") 'company-show-doc-buffer)
             (define-key company-active-map (kbd "C-w") 'evil-delete-backward-word)))

(define-key helm-map "\C-h" 'delete-backward-char)
(define-key helm-map "\C-w" 'evil-delete-backward-word)

(evil-define-key 'normal neotree-mode-map "q" 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "ESC") 'evil-window-next)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map "\C-j" 'neotree-enter)
(evil-define-key 'normal neotree-mode-map "\C-j" 'neotree-enter)
(evil-define-key 'normal neotree-mode-map "\M-t" 'neotree-hide)

(global-set-key [f8] 'help)
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "C-w") 'evil-delete-backward-word)
(global-set-key [M-kanji] 'ignore)

