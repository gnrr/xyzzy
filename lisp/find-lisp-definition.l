;;; find-lisp-definition.l
;;;
;;; install: add following lines to your .xyzzy
;;;   (require "find-lisp-definition")
;;;   (global-set-key #\M-\s 'find-lisp-definition)
;;;

;;;
;;; variables
;;;
(defvar *find-lisp-definition-dirs* *load-path*
  "find-lisp-definition で定義元を検索するときの検索対象のディレクトリをリストで指定する。")

(defvar *find-lisp-definition-buffer-read-only* t
  "find-lisp-definition で定義元のファイルを開いたとき read-only で開くかどうかを指定。
non-nil なら read-only で開く。")

(defvar *find-lisp-definition-buffer-other-window* t
  "結果を別のウィンドウで開くかどうかを指定。non-nil なら 別のウィンドウで開く。")

;;;
;;; command
;;;
(defun find-lisp-definition (&optional sym)
  "シンボルの定義を決まったディレクトリ配下の *.l から探す。
ディレクトリは `*find-lisp-definition-dirs*' で指定。"
  (interactive "sSymbol: " :default0 (word-near-point))
  (if (> (length sym) 0)
      (message (find-lisp-definition-internal sym))
    (message "シンボル名が入力されていません。")))

(global-set-key #\M-\s 'find-lisp-definition)

;;;
;;; internal function
;;;
(defun find-lisp-definition-internal (sym)
  ""
  (flet ((get-re (type name)
           (compile-regexp
            (format nil "^[ \t]*\([ \t]*~A[ \t]+~A[ \t]+\("
                    (case type ('var "defvar") ('func "defun") ('bfunc "si::defun-builtin") ('macro "defmacro"))
                    name))))
    (let ((type (find-lisp-definition-arbit-symbol-type sym)))
      (cond ((null type) (format nil "~A は 関数でもマクロでも変数でもありません。" sym))
            (t (multiple-value-bind (file pos)
                   (find-lisp-definition-scan (get-re type sym) *find-lisp-definition-dirs*)
                 (cond ((null file) (format nil "~A の定義が見つかりませんでした。" sym))
                       (t (let ((buf (ed::find-file-internal file t nil nil t *find-lisp-definition-buffer-read-only*))
                                (switch-func (if *find-lisp-definition-buffer-other-window*
                                                 #'switch-to-buffer-other-window #'switch-to-buffer)))
                            (funcall switch-func buf)
                            (goto-char pos))
                          (format nil "~A に定義がありました。" file)))))))))


(defun find-lisp-definition-arbit-symbol-type (sym-name)
  ""
  (flet ((ask-a-or-b (pred)
           (let* ((pred-list '((var-or-func "Var or Func ? " ((#\v . var) (#\f . func)))
                               (var-or-macro "Var or Macro ? " ((#\v . var) (#\m . macro)))))
                  (q (assoc pred pred-list))
                  (prompt (second q))
                  (allows (third q)))
             (minibuffer-prompt prompt)
             (loop
               (let ((ans (assoc (read-char *keyboard*) allows)))
                 (when ans (return (cdr ans))))))))
    (let* ((sym (intern sym-name))
           (var (boundp sym))
           (func (fboundp sym))
           (bfunc (builtin-function-p sym))
           (macro (macro-function sym)))
      (cond (bfunc 'bfunc)
            ((and var macro) (ask-a-or-b 'var-or-macro))
            ((and var func) (ask-a-or-b 'var-or-func))
            (macro 'macro)
            (func 'func)
            (var 'var)
            (t nil)))))

(defun find-lisp-definition-scan (pattern dir-list)
  ""
  (let (result)
    (dolist (d dir-list)
      (when (and (file-exist-p d)
                 (file-directory-p d))
        (setq result (car (scan-files-invisivle pattern d #'match-beginning :once t :wild "*.l" :regexp t))))
      (when result (return)))
    (values (car result) (second result))))

;;;
;;; utilities
;;;
(defun scan-files-invisivle (pattern dir match-func &key once wild case-fold regexp)
  ""
  (let ((files (directory dir :absolute t :recursive t :wild wild :file-only t ))
        result fr)
    (dolist (f files)
      (setq fr (scan-file-single-invisible pattern f match-func :once once :case-fold case-fold :regexp regexp))
      (when fr (push (cons f fr) result) (when :once (return))))
    result))
      
(defun scan-file-single-invisible (pattern file match-func &key once case-fold regexp)
  ""
  (let ((buf (create-new-buffer "*scan*"))
        result)
    (when regexp (compile-regexp pattern case-fold))
    (set-buffer buf)
    (insert-file-contents file)
    (while (scan-buffer pattern :no-dup t :case-fold case-fold :regexp regexp)
      (push (funcall match-func 0) result)
      (when :once (return)))
    (delete-buffer buf)
    result))

(defun builtin-function-p (symbol)
  "symbol がビルトイン関数かどうかを返す。"
  (and (fboundp symbol)
       (si::*builtin-function-p (symbol-function symbol))))

;;; find-lisp-definition.l ends here
