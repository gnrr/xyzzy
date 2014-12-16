;;;
;;; view-mode.l
;;;
;;; my-customized view-mode
;;;
;;; install:
;;;   (require 'view-mode)
;;;
(provide "view-mode")
(in-package "editor")

(export '(view-mode *view-mode* *view-mode-hook* *view-mode-map*))

(defvar-local *view-mode* nil)
(defvar *view-mode-hook* nil)

;;;
;;; keymap
;;;
(set-extended-key-translate-table exkey-S-space #\F16)

(defvar *view-mode-map* nil)
(unless *view-mode-map*
  (setq *view-mode-map* (make-sparse-keymap))
  (define-key *view-mode-map* #\SPC 'next-page)
  (define-key *view-mode-map* #\F16 'previous-page)       ; S-SPACE
  (define-key *view-mode-map* #\n 'previous-page)
  (define-key *view-mode-map* #\h 'backward-char)
  (define-key *view-mode-map* #\l 'forward-char)
  (define-key *view-mode-map* #\j 'next-line)
  (define-key *view-mode-map* #\k 'previous-line)
  (define-key *view-mode-map* #\g 'beginning-of-buffer)
  (define-key *view-mode-map* #\G 'end-of-buffer)
  (define-key *view-mode-map* #\0 'beginning-of-line)
  (define-key *view-mode-map* #\4 'end-of-line)
  (define-key *view-mode-map* #\w 'forward-word)
  (define-key *view-mode-map* #\b 'backward-word)
  (define-key *view-mode-map* #\/ 'isearch-forward)
  (define-key *view-mode-map* #\s 'isearch-forward)
  (define-key *view-mode-map* #\q '(lambda () (interactive) (kill-buffer (selected-buffer)))))

;;;
;;; mode setting
;;;
(defun view-mode (&optional (arg nil sv))
  (interactive)
  (toggle-mode '*view-mode* arg sv)
  (if *view-mode*
      (progn
        (set-minor-mode-map *view-mode-map*)
        (setq buffer-read-only t)
        (run-hooks '*view-mode-hook*))
    (progn
      (unset-minor-mode-map *view-mode-map*)
      (setq buffer-read-only nil)))
  (update-mode-line))


(global-set-key '(#\C-x #\C-q) 'view-mode)

(pushnew '(*view-mode* . "view") *minor-mode-alist* :key #'car)

;;; view-mode.l ends here