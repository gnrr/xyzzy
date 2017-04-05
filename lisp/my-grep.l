;;; -*- encoding: utf-8 -*-
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
(defvar *my-grep-default-get-word-near-point* t)

(defvar *my-grep-default-mask* "*.l"
  "デフォルトとして使う検索対象のファイルの拡張子を指定する。
例: \"*.asm\" \"*.[ch]\" など")

;;;
;;; internal
;;;

;;; jump log
(defvar my-grep-jump-log '())

(defun my-grep-jlog-push ()
  (interactive)
  (push (cons (selected-buffer) (point)) my-grep-jump-log))

(defun my-grep-jlog-pop ()
  (interactive)
  (let ((l (pop my-grep-jump-log)))
    (if l
        (let ((buf (car l))
              (pt  (cdr l)))
          (switch-to-buffer buf)
          (goto-char pt))
      (message "Empty jump log"))))


;;; history
(define-history-variable *my-grep-history-dir* nil)       ; 終了時に保存
(setf (get 'my-grep-dir 'ed::minibuffer-history-variable) '*my-grep-history-dir*)

(define-history-variable *my-grep-history-str* nil)       ; 終了時に保存
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

(defun dummy ()
  (let ((old (user-homedir-pathname)))
    (defun my-grep-get-buffer-directory-namestring ()
      ;(dbg-msgbox 1)
      (let ((fname (get-buffer-file-name)))
        (setq old (append-trail-slash (directory-namestring (if fname
                                                                (directory-namestring fname)
                                                              old))))))))

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
;        (mask (second inputs)))
        (mask (split-string (second inputs) #\, t " "))) ; カンマ区切り
    (when (> (length str) 0)
      (ed::scan-files str mask dir)
      (my-grep-history-fix))))

(defun my-grep (&optional arg)
  (interactive "p")
  (my-grep-jlog-push)
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
  (define-key *grep-map* #\RET 'my-grep-first-error)
  ;; (define-key *grep-map* #\M-[ 'my-grep-jlog-pop)
  )

(add-hook 'ed::*grep-hook*  #'(lambda () (use-keymap *grep-map*)))
(add-hook 'ed::*grepd-hook* #'(lambda () (use-keymap *grep-map*)))

(global-set-key #\M-o 'my-grep)
(global-set-key #\M-@ 'my-grep-jlog-pop)
(dummy)                         ; for (my-grep-get-buffer-directory-namestring)

;; http://xyzzy.s53.xrea.com/wiki/index.php?tips%2Fgrep%20%A4%C7%C6%FE%CE%CF%A4%B7%A4%BF%CA%B8%BB%FA%CE%F3%A4%F2%B6%AF%C4%B4%C9%BD%BC%A8%A4%B9%A4%EB
(add-hook '*show-match-hook* 'ed::show-match)

(in-package "editor")
(defun grep-scan-file (file scanner)
  (let ((found nil))
    (while (funcall scanner)
      (setq found t)
      (let ((beg (progn (goto-bol) (point)))
	    (end (progn (goto-eol) (point))))
	(format t "~A:~D:~A~%" file (current-line-number) (buffer-substring beg end))
	(when (and *grep-highlight-match*
		   (buffer-stream-p *standard-output*))
	  (save-excursion
	    (set-buffer (buffer-stream-buffer *standard-output*))
	    (let ((p (- (buffer-stream-point *standard-output*) end 1)))
	      (apply #'set-text-attribute (+ (match-beginning 0) p) (+ (match-end 0) p)
		     'grep *grep-highlight-match*)
	      (goto-char (+ (match-end 0) p 1))
	      (while (and (not (eolp)) (funcall scanner))
		(setq p (point))
		(apply #'set-text-attribute (match-beginning 0) (match-end 0)
		       'grep *grep-highlight-match*)
		(goto-char (+ (match-end 0) 1)))
	      ))))
      (or (forward-char 1)
	  (return)))
    found))
(in-package "user")

;;; my-grep.l ends here
