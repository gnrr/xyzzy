;;; auto-save-scratch-buffer
;;;
;;; *scratch* �o�b�t�@��p�� auto-save-buffers
;;; �ۑ���� RAM disk ��z��
;;;
;;; �C���X�g�[�� (���̈�s�� .xyzzy �ɏ���)
;;;   (require "auto-save-scratch-buffer")

(provide "auto-save-scratch-buffer")
(in-package "editor")

(export '(auto-save-scratch-buffer
          *auto-save-scratch-buffer-interval*
          *auto-save-scratch-buffer-path*))

(defvar *auto-save-scratch-buffer-p* nil
  "auto-save-scratch-buffer �ŕۑ����Ȃ� non-nil")

(defvar *auto-save-scratch-buffer-interval* 10
  "�����ۑ�����܂ł̃A�C�h������")

(defvar *auto-save-scratch-buffer-path* "R:/scratch"
  "�����ۑ�����t�@�C���� path")

(defun auto-save-scratch-buffer ()
  "scratch �o�b�t�@�������Z�[�u����"
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