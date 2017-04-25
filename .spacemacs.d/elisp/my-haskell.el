(defun my-haskell/init ()
  (interactive)
  (dolist (c (string-to-list "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
    (evil-define-key 'insert haskell-mode-map (char-to-string c) 'my-haskell/insert-non-operator))
  (dolist (c (string-to-list ":!#$%&*+./<=>?@^|-~"))
    (evil-define-key 'insert haskell-mode-map (char-to-string c) 'my-haskell/insert-operator))
  (dolist (c (string-to-list "\"'`(["))
    (evil-define-key 'insert haskell-mode-map (char-to-string c) 'my-haskell/insert-pair))
  (evil-define-key 'insert haskell-mode-map "," 'my-haskell/insert-commna)
  (evil-define-key 'insert haskell-mode-map "." 'my-haskell/insert-dot)
  (setq company-begin-commands (append '(my-haskell/insert-non-operator
                                         my-haskell/insert-operator
                                         my-haskell/insert-pair
                                         my-haskell/insert-commna
                                         my-haskell/insert-dot)
                                       company-begin-commands)))


(defun my-haskell/insert-non-operator ()
  (interactive)
  (let ((p (point)))
    (when (and (member (preceding-char) (string-to-list ":!#$%&*+./<=>?@^|-~)],"))
               (not (nth 3 (syntax-ppss p)))
               (not (equal p (line-beginning-position)))
               (not (my-haskell--behind-dot-dot?)))
      (insert " "))
    (self-insert-command 1)))


(defun my-haskell/insert-operator ()
  (interactive)
  (let ((p (point)))
    (when (not (or (member (preceding-char) (string-to-list ":!#$%&*+./<=>?@^|-~([ "))
                   (nth 3 (syntax-ppss p))
                   (equal p (line-beginning-position))))
      (insert " "))
    (self-insert-command 1)))


(defun my-haskell/insert-pair ()
  (interactive)
  (when (not (or (member (preceding-char) (string-to-list "([ "))
                 (nth 3 (syntax-ppss (point)))
                 (equal (point) (line-beginning-position))))
    (insert " "))
  (self-insert-command 1))


(defun my-haskell/insert-commna ()
  (interactive)
  (insert ",")
  (when (not (nth 3 (syntax-ppss (point))))
    (insert " ")))


(defun my-haskell/insert-dot ()
  (interactive)
  (when (not (nth 3 (syntax-ppss (point))))
    (cond ((my-haskell--behind-space-dot?)
           (delete-backward-char 2)
           (insert "."))
          ((or (my-haskell--just-after-variable?)
               (equal (preceding-char) 41))
           (insert " "))))
  (insert "."))


(defconst my-haskell--characters-for-var-initials (string-to-list "abcdefghijklmnopqrstuvwxyz_"))
(defconst my-haskell--characters-for-variables (string-to-list "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'"))
(defconst my-haskell--lowercase-alphabets (string-to-list "abcdefghijklmnopqrstuvwxyz"))
(defconst my-haskell--uppercase-alphabets (string-to-list "ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
(defconst my-haskell--numbers (string-to-list "0123456789"))


(defun my-haskell--behind-space-dot? ()
  (and (equal (char-before (- (point) 1)) 32)
       (equal (char-before (point)) 46)))


(defun my-haskell--behind-dot-dot? ()
  (and (equal (char-before (- (point) 1)) 46)
       (equal (char-before (point)) 46)))


(defun my-haskell--just-after-variable? (&optional p)
  (setq p (or p (point)))
  (let ((c (char-before p)))
    (or (and (or (equal c 32)
                 (equal p (line-beginning-position)))
             (member (char-before (+ p 1)) my-haskell--characters-for-var-initials))
        (and (member c my-haskell--characters-for-variables)
             (my-haskell--just-after-variable? (- p 1))))))


(defun my-haskell--behind-number? (&optional p)
  (cond (p
         (let ((c (char-before)))
           (or (equal c 32)
               (and (member c my-haskell--numbers)
                    (my-haskell--behind-number? (- p 1))))))
        (t
         (and (member c my-haskell--numbers)
              (my-haskell--behind-number? (- (point) 1))))))


(defun my-haskell--behind-number-dot? (&optional p)
  (cond (p
         (let ((c (char-before)))
           (or (equal c 32)
               (and (member c my-haskell--numbers)
                    (my-haskell--behind-number? (- p 1))))))
        (t
         (and (equal c 46)
              (my-haskell--behind-number? (- (point) 1))))))


(defun my-haskell--behind-module? (&optional p)
  (setq p (or p (point)))
  (let ((c (char-before p)))
    (or (member c my-haskell--uppercase-alphabets)
        (and (member c my-haskell--characters-for-variables)
             (my-haskell--behind-module? (- p 1))))))


(defun my-haskell--behind-module-dot? (&optional p)
  (cond (p
         (let ((c (char-before p)))
           (or (member c my-haskell--uppercase-alphabets)
               (and (member c my-haskell--characters-for-variables)
                    (my-haskell--behind-module-dot? (- p 1))))))
        (t
         (and (equal (preceding-char) 46)
              (my-haskell--behind-modue-dot? (- (point) 1))))))

(add-hook 'haskell-mode-hook 'my-haskell/init)
