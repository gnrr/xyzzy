;;;
;;; tree-find.l
;;;
;;; open file from result of "tree /f"
;;;
;;; install:
;;;   (require "tree-find")
;;;
;(require "user")
(provide "tree-find")

;;;
;;; customize
;;;
(defvar *tree-mode-default-top-directory* "C:/xyzzy")

;;;
;;; internal
;;;
(defvar tree-mode-buf-name "*tree*")


;;; history
(define-history-variable *tree-mode-history-dir* nil)       ; 終了時に保存
(setf (get 'tree-mode-dir 'ed::minibuffer-history-variable) '*tree-mode-history-dir*)

(define-history-variable *tree-mode-history-str* nil)           ; 終了時に保存
(setf (get 'tree-mode-str 'ed::minibuffer-history-variable) '*tree-mode-history-str*)

;;; utilities
(defun get-current-line ()
  (let ((bol (save-excursion (goto-bol) (point)))
        (eol (save-excursion (goto-eol) (point))))
    (buffer-substring bol eol)))

(defun tree-mode-read-directory (default-dir)
  ;(dbg-msgbox 3)
  (let ((dir (read-directory-name "Directory: "
                                  :default default-dir
                                  :history 'tree-mode-dir)))
    (if (and (file-exist-p dir) (file-directory-p  dir))
        dir
      (progn
        (error (format "No such directory %s" dir))
        nil))))

(defun tree-mode-get-buffer-directory-namestring ()
  ;(dbg-msgbox 1)
  (let ((fname (get-buffer-file-name)))
    (append-trail-slash (directory-namestring (if fname
                                                  (directory-namestring fname)
                                                (user-homedir-pathname))))))

(defun tree-mode-history-fix ()
  (labels ((upcase-drive-letter (s)
             (if (char= #\: (char s 1))
                 (string-upcase s :start 0 :end 1)
               s)))
    (setq *tree-mode-history-dir*
          (mapcar #'upcase-drive-letter
                  (remove-duplicates *tree-mode-history-dir* :test #'string-equal :from-end t)))
    (setq *tree-mode-history-str*
          (mapcar #'upcase-drive-letter
                  (remove-duplicates *tree-mode-history-str* :test #'string-equal :from-end t)))))

(defun tree-mode-setup-buffer (dir)
  (let ((cmd (concat "tree /f " dir))
        (buf (create-new-buffer (concat "*tree-" (car (last (split-string dir "/"))) "*"))))
    (setup-temp-buffer buf)
    (execute-shell-command cmd nil buf)
    (delete-other-windows)
    ;; (setq buffer-read-only t)
    (view-mode)
    (goto-line 4)
    (tree-mode)))

(defun tree-mode-get-path ()
  (let ((line (get-current-line)))
    (cond ((< (current-line-number) 4) nil)
          ((string-match "[─]" line) nil)                                ; directory
          ((string= (car (last (split-string line "[^ ─]" t))) "") nil)  ; empty line
          (t (let* ((top (concat (substitute-string (save-excursion (goto-line 3) (get-current-line)) "\\\\" "/") "/"))
                    (dirs "")
                    (fn (car (last (split-string line " " t))))
                    (ind-min (string-match "[^ ]+$" line))
                    (ind ind-min))
               (save-excursion
                 (while (> (current-line-number) 4)
                   (previous-line)
                   (setq line (get-current-line))
                   (setq ind (string-match "[└├─]" line))
                   ;; (msg-box "~s" ind)
                   (when (and (numberp ind) (< ind ind-min))
                     (setq ind-min ind)
                     (setq dirs (concat (car (last (split-string line "[─]" t))) "/" dirs)))))
               ;; (msgbox "~s")
               (concat top dirs fn))))))
;;;
;;; command
;;;
(defun tree-mode-open-file ()
  (interactive)
  (let ((path (tree-mode-get-path)))
    (cond ((not path) ())
          ((file-exist-p path) (let ((*find-file-hooks*  '(view-mode)))
                                 (find-file path)
                                 ;; (delete-buffer tree-mode-buf-name)
                                 ))
          (t (message "file not exists ~s" path)))))

(defun tree-find (dir)
  (interactive (list (tree-mode-read-directory (tree-mode-get-buffer-directory-namestring))))
  (tree-mode-setup-buffer dir)
  (tree-mode-history-fix))

;;;
;;; keymap
;;;
(defvar *tree-mode-map* nil)
(unless *tree-mode-map*
  (setq *tree-mode-map* (make-sparse-keymap))
  (define-key *tree-mode-map* #\RET 'tree-mode-open-file))

(global-set-key #\M-i 'tree-find)

;;;
;;; mode setting
;;;
(defun tree-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'tree-mode)
  (setq mode-name "tree")
  (use-keymap *tree-mode-map*))

;;; tree-find.l ends here
