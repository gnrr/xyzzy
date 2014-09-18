;;; scratch-util.l
;;;
;;; scratch buffer utility
;;;
(require "util")
(provide "scratch-util")
(in-package "editor")

;;
(let ((buf (find-buffer "*scratch*")))
  (when buf
    (with-set-buffer
      (set-buffer buf)
      (make-local-variable 'need-not-save)
      (setq need-not-save nil))))

(export '(scratch-util-save scratch-util-read scratch-create
          *scratch-util-dir* *scratch-util-name*))

(defvar *scratch-util-dir* "~"
  "保存ファイルをつくる場所")

(defvar *scratch-util-name* "scratch-bak"
  "保存ファイルの名前")

(defvar *scratch-util-buf* "*scratch*")

;;; command
(defun scratch-util-save ()
  (let ((buf *scratch-util-buf*)
        (path (concat (append-trail-slash *scratch-util-dir*)
                      *scratch-util-name*)))
    (when (and (find-buffer buf)
               (buffer-modified-p buf)
               (< 0 (buffer-size buf)))
      (with-set-buffer
        (set-buffer buf)
        (write-file path t)
        (set-buffer-modified-p nil))))
  t)


(defun scratch-util-read ()
  (interactive)
  (let ((buf *scratch-util-buf*)
        (path (concat (append-trail-slash *scratch-util-dir*)
                      *scratch-util-name*)))
    (cond ((not (file-exist-p path)) (message "not exist ~A" path))
          ((> (buffer-size buf) 0) (switch-to-buffer (find-file-internal path))
                                   (lisp-interaction-mode))
          (t (switch-to-buffer buf)
             (insert-file path)))))

(defun scratch-create (&optional arg)
  "*scratch* バッファを作る。すでにあるときはそれに切り替え。"
  (interactive)
  (let* ((scratch "*scratch*")
         (buf (find-buffer scratch)))
    (cond (buf (switch-to-buffer buf))
          (t (set-buffer (get-buffer-create scratch))
             (lisp-interaction-mode)
             (erase-buffer (selected-buffer))
             (message "~A バッファを作成しました。" scratch)))))

;(defalias 'scratch 'scratch-create)

(add-hook '*query-kill-xyzzy-hook* 'scratch-util-save)

;;; scratch-util ends here
