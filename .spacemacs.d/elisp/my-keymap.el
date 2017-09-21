(defun my-keymap/evil-normal-c$ ()
  (interactive)
  (let ((begin (progn (current-column) (point)))
        (end (progn (end-of-line) (point))))
    (evil-change begin end)))

(defun my-keymap/evil-insert-C-u ()
  (interactive)
  (let ((begin (progn (current-column) (point)))
        (end (progn (evil-first-non-blank) (point))))
    (evil-change begin end)))

(defun my-keymap/delete-backward-word-10-times ()
  (interactive)
  (loop for i from 0 to 9 do
        (evil-delete-backward-word)))

(defun my-keymap/save-if-file-buffer ()
  (interactive)
  (when (not (or (string-match "\\*.+\\*" (buffer-name))
                 (string-match "intero:backend:.*" (buffer-name))
                 (eq major-mode 'dired-mode)))
    (when (string-equal major-mode "c++-mode")
      (clang-format-buffer))
    (save-buffer)))

(defun my-keymap/remap-company-mode ()
  (interactive)
  (dolist (m (list company-active-map company-search-map))
    (define-key m (kbd "<tab>") 'hippie-expand)
    (define-key m (kbd "C-h") 'delete-backward-char)
    (define-key m (kbd "C-i") 'hippie-expand)
    (define-key m (kbd "C-j") 'company-complete-selection)
    (define-key m (kbd "C-m") 'company-complete-selection)
    (define-key m (kbd "C-n") 'company-select-next)
    (define-key m (kbd "C-p") 'company-select-previous)
    (define-key m (kbd "C-q") 'company-show-doc-buffer)
    (define-key m (kbd "C-w") 'evil-delete-backward-word)))

(defun my-keymap-toggle-flycheck-error-buffer ()
  "toggle a flycheck error buffer."
  (interactive)
  (if (string-match-p "Flycheck errors" (format "%s" (window-list)))
      (dolist (w (window-list))
        (when (string-match-p "*Flycheck errors*" (buffer-name (window-buffer w)))
          (delete-window w)))
    (flycheck-list-errors)))

(defun my-keymap/remap-helm-mode ()
  (interactive)
  (define-key helm-map [f8] 'help)
  (define-key helm-map "\C-j" 'helm-confirm-and-exit-minibuffer)
  (define-key helm-map "\C-h" 'delete-backward-char)
  (define-key helm-map "\C-w" 'evil-delete-backward-word))

(setq evil-want-C-i-jump t)
;;(add-hook 'evil-normal-state-entry-hook 'my-keymap/save-if-file-buffer)

(define-key evil-normal-state-map [escape] 'my-keymap/save-if-file-buffer)

(define-key evil-insert-state-map "\M-r" 'quickrun)
(define-key evil-normal-state-map "\M-r" 'quickrun)
(define-key evil-insert-state-map "\M-v" 'helm-imenu)
(define-key evil-normal-state-map "\M-v" 'helm-imenu)
(define-key evil-insert-state-map "\M-l" 'my-keymap-toggle-flycheck-error-buffer)
(define-key evil-normal-state-map "\M-l" 'my-keymap-toggle-flycheck-error-buffer)

(define-key evil-normal-state-map "\M-f" 'avy-migemo-goto-char-2)
(define-key evil-normal-state-map "\C-h" 'evil-backward-char)
(define-key evil-normal-state-map "\C-k" 'my-keymap/evil-normal-c$)
(define-key evil-normal-state-map "\C-n" 'tabbar-forward-tab)
(define-key evil-normal-state-map "\C-p" 'tabbar-backward-tab)
(define-key evil-normal-state-map (kbd "\\") 'ignore)
(define-key evil-normal-state-map "\M-s" 'swiper)

(define-key evil-insert-state-map "\C-a" 'evil-insert-line)
(define-key evil-insert-state-map "\C-e" 'move-end-of-line)
(define-key evil-insert-state-map "\C-d" 'evil-delete-char)
(define-key evil-insert-state-map "\C-h" 'delete-backward-char)
(define-key evil-insert-state-map "\C-i" 'hippie-expand)
(define-key evil-insert-state-map "\C-j" 'newline-and-indent)
(define-key evil-insert-state-map "\C-u" 'my-keymap/evil-insert-C-u)
(define-key evil-insert-state-map "\C-n" '(lambda () (interactive) (company-select-next) (company-select-previous)))
(define-key evil-insert-state-map "\C-p" '(lambda () (interactive) (company-select-previous) (company-select-next)))

(add-hook 'company-mode-hook 'my-keymap/remap-company-mode)
(add-hook 'helm-mode-hook 'my-keymap/remap-helm-mode)
(global-company-mode 1)

(define-key swiper-map "\C-j" 'ivy-done)
(define-key swiper-map "\C-u" 'my-keymap/delete-backward-word-10-times)

(evil-define-key 'normal dired-mode-map "\C-j" 'dired-find-file)

(evil-define-key 'normal quickrun--mode-map "q" 'evil-window-delete)

(define-key evil-normal-state-map "\M-w" 'helm-find-files)

(global-set-key [f8] 'help)
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "C-w") 'evil-delete-backward-word)
(global-set-key [M-kanji] 'ignore)

(keyboard-translate ?\C-j ?\C-m)
