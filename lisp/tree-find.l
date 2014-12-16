;;;
;;; tree-find.l
;;;
;;; open file from result of "tree /f"
;;;
;;; install:
;;;   (require 'tree-find)
;;;
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
  (let ((bol (progn (goto-bol) (point)))
        (eol (progn (goto-eol) (point))))
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

(defun tree-mode-get-path ()
  (let (top dirs fn line ind ind-min)
    (cond ((string-match "─+" (get-current-line)) nil)
          ((< (current-line-number) 4) nil)
          (t (progn
               (setq line (get-current-line))
               (setq ind-min (string-match "[^ ]+$" line))
               (setq fn (car (last (split-string line " " t))))
               (setq top (concat (save-excursion (goto-line 3) (get-current-line)) "/"))
                (save-excursion
                  (while (> (current-line-number) 3)
                    (previous-line)
                    (let ((line (get-current-line)))
                      (setq ind (string-match "─" line))
                      (when (and (numberp ind) (< ind ind-min))
                        (setq ind-min ind)
                        (setq dirs (concat (car (last (split-string line "[└├─ ]"))) "/" dirs))))))
                (concat top dirs fn))))))

(defun tree-mode-setup-buffer (dir)
  (let ((cmd (concat "tree /f " dir))
        (buf (create-new-buffer tree-mode-buf-name)))
    (setup-temp-buffer buf)
    (execute-shell-command cmd nil buf)
    (delete-other-windows)
    ;; (setq buffer-read-only t)
    (view-mode)
    (goto-line 4)
    (tree-mode)))

;;;
;;; command
;;;
(defun tree-mode-open-file ()
  (interactive)
  (let ((*find-file-hooks* '(view-mode)))
    (find-file (tree-mode-get-path)))
  (delete-buffer tree-mode-buf-name))

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