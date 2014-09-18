;;;
;;; util.l
;;;
;;; 他への影響がない小物を入れる
;;;   - キーバインドを変更しないもの
;;;   - エディタの振る舞いを変えないもの

(provide "util")

(export '(notf defalias))

;;
;; 桁数を求める
;;
(defun digit (n)
  "return digit for number."
  (setq n (truncate (1+ n)))
  (let ((d 0))
    (while (> n 1)
      (setq n (/ n 10))
      (incf d))
    d))

;; (digit 1000)
;; =>4
;; (digit 999)
;; =>3


;;;
;;; notf
;;;
(defmacro notf (var)
  "フラグを反転する。"
  `(setq ,var (not ,var)))

;;;
;;; defalias
;;;
(defmacro defalias (alias original &optional doc)
  `(setf (symbol-function ,alias) (symbol-function ,original)))

;;; loop-at-buffer
;;; e.g. (loop-at-buffer (line)
;;;        (dbg-msgbox line))
(defmacro loop-at-buffer ((var &optional buffer) &body body)
  "バッファを1行ずつ処理する。"
  (let ((gbuf (gensym))
        (gstream (gensym)))
    `(let* ((,gbuf (cond ((null ,buffer) (selected-buffer))
                         ((bufferp ,buffer) ,buffer)
                         (t (find-buffer ,buffer))))
            (,gstream (if ,gbuf (make-buffer-stream ,gbuf)
                        (error "\"~A\"という名前のバッファが見つかりません" ,buffer))))
       (loop
         (let ((,var (read-line ,gstream nil)))
           (unless ,var (return nil))
           ,@body)))))

;;; char-alphabet-p, char-number-p
(defun char-alphabet-p (ch)
  (if (char-not-greaterp #\a ch #\z) t
    nil))

(defun char-number-p (ch)
  (if (char<= #\0 ch #\9) t
    nil))

;;; windows-local-path-p
(defun windows-local-path-p (path)
  (let ((pos (position #\: path)))
    (if (and (= pos 1)
             (char-alphabet-p (char path 0))) t
      nil)))

;;; upcase-drive-letter
(defun upcase-drive-letter (s)
  (if (char= #\: (char s 1))
      (string-upcase s :start 0 :end 1)
    s))

;;; concat-path
(defun concat-path (path1 &rest path)
  (let ((ret (string-right-trim "/" (map-backslash-to-slash path1))))
	(dolist (p path ret)
	  (setq ret (concat ret "/" (string-trim "/" (map-backslash-to-slash p)))))))

;;; string<, string-lessp
(defun string-length< (x y)
  (cond ((< (length x) (length y)) t)
        ((> (length x) (length y)) nil)
        ((string< x y) t)
        (t nil)))

(defun string-length-lessp (x y)
  (cond ((< (length x) (length y)) t)
        ((> (length x) (length y)) nil)
        ((string-lessp x y) t)
        (t nil)))

;;; for
;;; e.g.: (for (i 1 10)
;;;         (dbg-msgbox i))
(defmacro for ((var start stop) &body body)
  (let ((gstop (gensym)))
    `(do ((,var ,start (1+ ,var)) (,gstop ,stop))
         ((>= ,var ,gstop))
       ,@body)))


;;; eol, bol
(defun eol ()
  "行末の位置を取得する。"
  (save-excursion
    (goto-eol)(point)))

(defun bol ()
  "行頭の位置を取得する。"
  (save-excursion
    (goto-bol)(point)))

;;; path-delim-to-slash       ￥ --> /
(defun path-delim-to-slash (path)
  "パス文字列内のバックスラッシュをスラッシュに置換する。"
  (substitute-string path "\\\\" "/"))

;;; path-delim-to-back-slash  / --> ￥
(defun path-delim-to-back-slash (path)
    "パス文字列内のスラッシュをバックスラッシュに置換する。"
  (substitute-string path "/" "\\\\"))

;;; msgbox for lisp debug
;;; usage: (dbg-msgbox args)
(defmacro dbg-msgbox (&rest vars)
  "デバッグ用 msgbox。"
  `(msgbox 
    (concat ,@(make-list (length vars) :initial-element "~S\n"))
    ,@vars))

;;; pme (print macro expand)
;;; http://www.shido.info/lisp/add2li.l.txt
;;; usage: (pme (macro-name args))[C-j]
(defmacro pme (mac)
  `(pprint-1 (macroexpand-1 ',mac)))

;;;           
;;; mod
;;;
(defun truename-mod (path)
  "mod: fixed removing trailing slash"
  (let ((endc (char path (1- (length path)))))
    (if (or (eq endc #\/)
            (eq endc #\\))
        (append-trail-slash (truename path))
      (truename path))))

(defun pprint-1 (s0)
  (pp-loop (substitute-string (format nil "~S" s0) "\n" "\\\\n"))
  (values))

(defun pp-loop (str0 &optional then)
  (if (and then (eql 0 (string-match " *[^ (]+" str0)))
      (let ((pe (match-end 0)))
    (insert (substring str0 0 pe))
    (lisp-newline-and-indent)
    (pp-loop (substring str0 pe) nil))
    (progn
      (string-match ")+\\|( *cond +\\|case +[^ (]+" str0)
      (let* ((px   (match-end 0))
         (str1 (substring str0 0 px))
         (pif0 (string-match "\\( *( *if +\\)\\|\\( *( *if +[^ (]+\\)" str1))
         (pif1 (match-end 2))
         (p1   (or pif1 px)))
    (if (and pif0 (< 0 pif0))
        (progn
          (insert (substring str0 0 pif0))
          (lisp-newline-and-indent)
          (insert (substring str0 pif0 p1)))
      (insert (substring str0 0 p1)))
    (lisp-newline-and-indent)
    (if (< p1 (length str0))
        (pp-loop (substring str0 p1) pif0))))))

;;; util.l ends here
