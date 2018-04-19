(with-eval-after-load 'rust-mode
  (setenv "LD_LIBRARY_PATH" (shell-command-to-string "printf '%s' $(rustup run nightly rustc --print sysroot)/lib"))
  (setq racer-rust-src-path (shell-command-to-string "printf '%s/lib/rustlib/src/rust/src' $(rustc --print sysroot)"))
  (define-key company-active-map "\C-q" 'racer-describe)
  (define-key company-search-map "\C-q" 'racer-describe)
  (evil-define-key 'insert rust-mode-map "\C-q" 'racer-describe)
  (evil-define-key 'normal rust-mode-map "\C-q" 'racer-describe)
  (evil-define-key 'normal rust-mode-map "\C-]" 'racer-find-definition)
  (evil-define-key 'normal rust-mode-map "\M-r" 'my-rust-run)
  (evil-define-key 'normal rust-mode-map "\M-t" 'my-rust-test)
  (evil-define-key 'insert rust-mode-map "," 'my-rust-insert-comma)
  (evil-define-key 'insert rust-mode-map ":" 'my-rust-insert-colon)
  (evil-define-key 'insert rust-mode-map ";" 'my-rust-insert-semicolon)
  (evil-define-key 'insert rust-mode-map "=" 'my-rust-insert-equal)
  (evil-define-key 'insert rust-mode-map "|" 'my-rust-insert-bar)
  (evil-define-key 'insert rust-mode-map ">" 'my-rust-insert-gt)
  (evil-define-key 'insert rust-mode-map "'" 'my-rust-insert-single-quote)
  (evil-define-key 'insert rust-mode-map "\"" 'my-rust-insert-double-quote)
  (evil-define-key 'insert rust-mode-map "{" 'my-rust-insert-curly-brace)
  (setq company-begin-commands (append '(my-rust-insert-colon
                                         my-rust-insert-equal
                                         my-rust-insert-bar
                                         my-rust-insert-curly-brace)
                                       company-begin-commands)))

(defun my-rust-init ()
  (interactive)
  (when (or (string-match ".*/.cargo/.*" (pwd))
            (string-match ".*.rustup/.*" (pwd)))
    (read-only-mode 1))
  ;;(setq company-begin-commands (append '(my-rust-insert-comma
  ;;                                       my-rust-insert-single-quote
  ;;                                       my-rust-insert-double-quote
  ;;                                       my-rust-insert-curly-brace
  ;;                                       my-rust-insert-bracket
  ;;                                       my-rust-insert-operator
  ;;                                       my-rust-insert-alphabet
  ;;                                       my-rust-insert-number)
  ;;                                     company-begin-commands))
  ;;(evil-define-key 'insert rust-mode-map "," 'my-rust-insert-comma)
  ;;(evil-define-key 'insert rust-mode-map "|" 'my-rust-insert-bar)
  ;;(evil-define-key 'insert rust-mode-map "'" 'my-rust-insert-single-quote)
  ;;(evil-define-key 'insert rust-mode-map "\"" 'my-rust-insert-double-quote)
  ;;(evil-define-key 'insert rust-mode-map "{" 'my-rust-insert-curly-brace)
  ;;(dolist (c (string-to-list "(["))
  ;;  (evil-define-key 'insert rust-mode-map (char-to-string c) 'my-rust-insert-bracket))
  ;;(dolist (c (string-to-list "+-*/=>"))
  ;;  (evil-define-key 'insert rust-mode-map (char-to-string c) 'my-rust-insert-operator))
  ;;(dolist (c (string-to-list "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
  ;;  (evil-define-key 'insert rust-mode-map (char-to-string c) 'my-rust-insert-alphabet))
  ;;(dolist (c (string-to-list "0123456789"))
  ;;  (evil-define-key 'insert rust-mode-map (char-to-string c) 'my-rust-insert-number))
  )

(defun my-rust-run ()
  (interactive)
  (let ((file-path (buffer-file-name)))
    (cond ((string-match (format "^.*/%s/src/bin/\\(.+\\)\\.rs$" my-rust--snowchains-crate) file-path)
           (let ((buffer (get-buffer "*snowchains*")))
             (when buffer
               (with-current-buffer buffer
                 (erase-buffer))))
           (let ((problem-name (match-string 1 file-path)))
             (term-run "snowchains" "*snowchains*" "submit" problem-name "-l" "rust")))
          ((string-match "^.*/src/bin/\\(.+\\)\\.rs$" file-path)
           (cargo-process-run-bin (match-string 1 file-path)))
          ((string-match "^.*/examples/\\(.+\\).rs$" file-path)
           (cargo-process-run-example (match-string 1 file-path)))
          (t
           (cargo-process-run)))))

(defun my-rust-test ()
  (interactive)
  (let ((file-path (buffer-file-name)))
    (cond ((string-match (format "^.*/%s/src/bin/\\(.+\\)\\.rs$" my-rust--snowchains-crate) file-path)
           (let ((buffer (get-buffer "*snowchains*")))
             (when buffer
               (with-current-buffer buffer
                 (erase-buffer))))
           (let ((problem-name (match-string 1 file-path)))
             (term-run "snowchains" "*snowchains*" "judge" problem-name "-l" "rust")))
          ((string-match "^.*/src/bin/\\(.+\\)\\.rs$" file-path)
           (cargo-process--start "Test Bin" (concat "cargo test --bin " (match-string 1 file-path))))
          (t
           (cargo-process-test)))))

(defun my-rust-insert-comma ()
  (interactive)
  (insert ",")
  (when (not (or (eolp)
                 (nth 3 (syntax-ppss))
                 (nth 5 (syntax-ppss))))
    (insert " ")))

(defun my-rust-insert-colon ()
  (interactive)
  (cond ((and (string-equal (buffer-substring (- (point) 2) (point)) ": ")
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (delete-backward-char 1)
         (self-insert-command 1))
        ((and (equal (preceding-char) (string-to-char ">"))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (self-insert-command 2))
        ((not (or (nth 3 (syntax-ppss))
                  (nth 5 (syntax-ppss))))
         (self-insert-command 1)
         (insert " "))
        (t
         (self-insert-command 1))))

(defun my-rust-insert-semicolon ()
  (interactive)
  (self-insert-command 1)
  (when (and (eolp)
             (not (or (nth 3 (syntax-ppss))
                      (nth 5 (syntax-ppss)))))
    (rust-format-buffer)))

(defun my-rust-insert-equal ()
  (interactive)
  (cond ((and (string-equal " <>" (buffer-substring (- (point) 2) (+ (point) 1)))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (delete-char 1)
         (insert "= "))
        ((and (string-equal "<>" (buffer-substring (- (point) 1) (+ (point) 1)))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (delete-char 1)
         (delete-backward-char 1)
         (insert " <= "))
        ((and (string-equal "= " (buffer-substring (- (point) 2) (point)))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (delete-backward-char 1)
         (insert "= "))
        ((and (member (preceding-char) (string-to-list "+-*/&|^%!=<> "))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (insert "= "))
        ((not (or (nth 3 (syntax-ppss))
                  (nth 5 (syntax-ppss))))
         (insert " = "))
        (t
         (self-insert-command 1))))

(defun my-rust-insert-bar ()
  (interactive)
  (cond ((and (equal (preceding-char) (string-to-char "("))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (insert "||")
         (backward-char 1))
        ((and (string-equal "(move" (buffer-substring (- (point) 5) (point)))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (insert " ||")
         (backward-char 1))
        ((and (or (string-equal "= " (buffer-substring (- (point) 2) (point)))
                  (string-equal "=move " (buffer-substring (- (point) 6) (point)))
                  (string-equal "= move " (buffer-substring (- (point) 7) (point))))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (insert "||;")
         (backward-char 2))
        ((and (or (string-equal "=" (buffer-substring (- (point) 1) (point)))
                  (string-equal "=move" (buffer-substring (- (point) 5) (point)))
                  (string-equal "= move" (buffer-substring (- (point) 6) (point))))
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (insert " ||;")
         (backward-char 2))
        ((and (string-equal (buffer-substring (point) (+ (point) 1)) "|")
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (forward-char 1))
        (t
         (self-insert-command 1))))

(defun my-rust-insert-gt ()
  (interactive)
  (cond ((and (string-equal (buffer-substring (- (point) 2) (point)) "= ")
              (not (or (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (delete-backward-char 1)
         (insert "> "))
        (t
         (self-insert-command 1))))

(defun my-rust-insert-single-quote ()
  (interactive)
  (when (not (or (member (preceding-char) (string-to-list "br&([< "))
                 (nth 3 (syntax-ppss))
                 (nth 5 (syntax-ppss))))
    (insert " "))
  (self-insert-command 1))

(defun my-rust-insert-double-quote ()
  (interactive)
  (when (not (or (member (preceding-char) (string-to-list "br#([ "))
                 (nth 3 (syntax-ppss))
                 (nth 5 (syntax-ppss))))
    (insert " "))
  (self-insert-command 1))

(defun my-rust-insert-curly-brace ()
  (interactive)
  (cond ((and (eolp)
              (string-equal "= " (buffer-substring (- (point) 2) (point)))
              (not (or (string-equal "== " (buffer-substring (- (point) 3) (point)))
                       (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (insert ";")
         (backward-char 1)
         (self-insert-command 1))
        ((and (eolp)
              (equal (preceding-char) (string-to-char "="))
              (not (or (string-equal "==" (buffer-substring (- (point) 2) (point)))
                       (nth 3 (syntax-ppss))
                       (nth 5 (syntax-ppss)))))
         (insert " ;")
         (backward-char 1)
         (self-insert-command 1))
        ((not (or (member (preceding-char) (string-to-list "([: "))
                  (nth 3 (syntax-ppss))
                  (nth 5 (syntax-ppss))))
         (insert " ")
         (self-insert-command 1))
        (t
         (self-insert-command 1))))

(defun my-rust-insert-bracket ()
  (interactive)
  (when (and (member (preceding-char) (string-to-list ",+-*/|=>"))
             (not (or (nth 3 (syntax-ppss))
                      (nth 5 (syntax-ppss)))))
    (insert " "))
  (self-insert-command 1))





(defun my-rust-insert-operator ()
  (interactive)
  (when (not (or (member (preceding-char) (string-to-list "+-*/=<>&| "))
                 (nth 3 (syntax-ppss (point)))))
    (insert " "))
  (self-insert-command 1))

(defun my-rust-insert-alphabet ()
  (interactive)
  (when (and (member (preceding-char) (string-to-list "+/=>:"))
             (not (equal (char-before (- (point) 1)) (string-to-char ":")))
             (not (nth 3 (syntax-ppss (point)))))
    (insert " "))
  (self-insert-command 1))

(defun my-rust-insert-number ()
  (interactive)
  (when (and (member (preceding-char) (string-to-list "+*/=<>&|:"))
             (not (equal (char-before (- (point) 1)) (string-to-char ":")))
             (not (nth 3 (syntax-ppss (point)))))
    (insert " "))
  (self-insert-command 1))

(defconst my-rust--snowchains-crate "contest/rs")

(add-hook 'rust-mode-hook 'my-rust-init)
