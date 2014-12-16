;;;
;;; my-grep.l
;;;
;;; emacs の moccur-grep と操作性互換な grep コマンド
;;; moccur-grep: http://www.bookshelf.jp/cgi-bin/goto.cgi?file=meadow&node=color-moccur

(require "grepd")
(require "view-mode")
(require "c-mode")
(provide "my-grep")

;;;
;;; customize
;;;
(defvar *my-grep-default-get-word-near-point* t
  "検索したい文字列をバッファのポイント位置周辺から拾うかどうかを指定する。
t   拾う
nil 拾わない
注意: 正規表現を使う場合は、この指定は無視される。")

(defvar *my-grep-default-mask* "*.l"
  "デフォルトとして使う検索対象のファイルの拡張子を指定する。
例: \"*.asm\" \"*.[ch]\" など")

;;;
;;; internal
;;;

;;; history
(define-history-variable *my-grep-history-dir* nil)       ; 終了時に保存
(setf (get 'my-grep-dir 'ed::minibuffer-history-variable) '*my-grep-history-dir*)

(define-history-variable *my-grep-history-str* nil)           ; 終了時に保存
(setf (get 'my-grep-str 'ed::minibuffer-history-variable) '*my-grep-history-str*)

;;; utilities
(defun my-grep-get-word-near-point ()
  ;(dbg-msgbox 4)
  (or (selection-start-end (start end) (buffer-substring start end))
      (save-excursion
        (buffer-substring (progn (skip-syntax-spec-forward "w_") (point))
                          (progn (skip-syntax-spec-backward "w_") (point))))))

(defun my-grep-read-directory (default-dir)
  ;(dbg-msgbox 3)
  (let ((dir (read-directory-name "Directory: "
                                  :default default-dir
                                  :history 'my-grep-dir)))
    (if (and (file-exist-p dir) (file-directory-p  dir))
        dir
      (progn
        (error (format "No such directory %s" dir))
        nil))))

(defun my-grep-read-regexp (&optional mask)
  ;(dbg-msgbox 2)
  (let ((regexp ed::*grep-regexp-search*)
        (wd nil) (init nil) input)
    (setq wd (when (and (null regexp)
                        *my-grep-default-get-word-near-point*)
               (my-grep-get-word-near-point)))   ;; get a word near the point as default regexp string
    (setq init (concat wd "\t" mask))
    (setq input (read-string (format nil "~A and FileMask: " (if regexp "Regexp" "String"))
                 :default init
                 :history 'my-grep-str))
    (split-string input "\t" t)))

(defun my-grep-get-buffer-directory-namestring ()
  ;(dbg-msgbox 1)
  (let ((fname (get-buffer-file-name)))
    (append-trail-slash (directory-namestring (if fname
                                                  (directory-namestring fname)
                                                (user-homedir-pathname))))))

(defun my-grep-history-fix ()
  (labels ((upcase-drive-letter (s)
             (if (char= #\: (char s 1))
                 (string-upcase s :start 0 :end 1)
               s)))
    (setq *my-grep-history-dir*
          (mapcar #'upcase-drive-letter
                  (remove-duplicates *my-grep-history-dir* :test #'string-equal :from-end t)))
    (setq *my-grep-history-str*
          (mapcar #'upcase-drive-letter
                  (remove-duplicates *my-grep-history-str* :test #'string-equal :from-end t)))))

;;;
;;; command
;;;
(defun my-grep-internal (dir inputs)
  (interactive (list (my-grep-read-directory (my-grep-get-buffer-directory-namestring))
                     (my-grep-read-regexp *my-grep-default-mask*)))
  (let ((cur-buf (selected-buffer)))
    (dolist (buf (buffer-list))
      (set-buffer buf)
      (when *narrowing-region-state* (widen)))
    (set-buffer cur-buf))
  (let ((str (first inputs))
        (mask (second inputs)))
    (when (> (length str) 0)
      (ed::scan-files str mask dir)
      (my-grep-history-fix))))

(defun my-grep (&optional arg)
  (interactive "p")
  (let ((ed::*grep-case-fold-search* nil)
        (ed::*grep-subdir* t)
        (ed::*grep-name-only* nil)
        (ed::*grep-regexp-search* (if arg t nil)))
    (call-interactively 'my-grep-internal))
  (view-mode 1)
  (c-mode)
  (turn-off-paren)
  (use-keymap *grep-map*))

;;;
;;; keymap
;;;

(defun my-grep-first-error ()
  (interactive)
  (let ((*find-file-hooks* #'(lambda () (view-mode 1))))
    (first-error)))

(defvar *grep-map* nil)
(unless *grep-map*
  (setq *grep-map* (make-sparse-keymap))
  (define-key *grep-map* #\RET 'my-grep-first-error))

(add-hook 'ed::*grep-hook*  #'(lambda () (use-keymap *grep-map*)))
(add-hook 'ed::*grepd-hook* #'(lambda () (use-keymap *grep-map*)))

(global-set-key #\M-o 'my-grep)

;;; my-grep.l ends here
