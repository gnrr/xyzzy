;;; auto-save-scratch-buffer
;;;
;;; *scratch* バッファ専用の auto-save-buffers
;;; 保存先は RAM disk を想定
;;;
;;; インストール (下の一行を .xyzzy に書く)
;;;   (require "auto-save-scratch-buffer")

(provide "auto-save-scratch-buffer")
(in-package "editor")

(export '(auto-save-scratch-buffer
          *auto-save-scratch-buffer-interval*
          *auto-save-scratch-buffer-path*))

(defvar *auto-save-scratch-buffer-p* nil
  "auto-save-scratch-buffer で保存中なら non-nil")

(defvar *auto-save-scratch-buffer-interval* 10
  "自動保存するまでのアイドル時間")

(defvar *auto-save-scratch-buffer-path* "R:/scratch"
  "自動保存するファイルの path")

(defun auto-save-scratch-buffer ()
  "scratch バッファを自動セーブする"
  (let ((buf (find-buffer "*scratch*")))
    (when (and (eq (selected-buffer) buf)
               (buffer-modified-p buf)
               (check-valid-pathname (directory-namestring *auto-save-scratch-buffer-path*)))
      (setf *auto-save-scratch-buffer-p* t)
      (set-buffer buf)
      (write-file *auto-save-scratch-buffer-path* t)
      (set-buffer-modified-p nil buf)
      (refresh-screen 0)
      (message "saved scratch.")
      (setf *auto-save-scratch-buffer-p* nil))))

(add-hook '*post-command-hook*
          #'(lambda ()
            (stop-timer 'auto-save-scratch-buffer)
            (start-timer *auto-save-scratch-buffer-interval* 'auto-save-scratch-buffer t)))

;;; auto-save-scratch-buffer ends here
