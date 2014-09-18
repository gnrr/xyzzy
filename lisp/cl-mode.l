;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;;
; cl-mode
; based on scheme-mode by MATSUOKA Hiroshi
;
(require "lispmode")
(provide "cl-mode")

(in-package "editor")
(export '(*cl-mode-hook*
          *cl-keyword-file*
          *cl-mode-map*
          *cl-indent-map*
          cl-mode
          *cl-run-command*
          *cl-run-pop-to-args*
          make-cl-scratch
          *cl-mode-scratch-buffer*
          *cl-process*
          *cl-process-open-hook*
          *cl-process-close-hook*
          *cl-process-send-filter*
          *cl-process-read-filter*
          *cl-view-mode-map*
          *cl-mode-version*
          cl-view-mode))

(defvar *cl-mode-version* "based-scheme-mode-20090118")
;;; cl-mode
(defvar *cl-mode-map* nil)
(unless *cl-mode-map*
  (setq *cl-mode-map* (make-sparse-keymap))
  (define-key *cl-mode-map* #\RET 'lisp-newline-and-indent)
  (define-key *cl-mode-map* #\LFD #'(lambda () (interactive) (cl-eval-last-sexp) (newline)))
  (define-key *cl-mode-map* '(#\C-c #\C-e) 'cl-eval-current-buffer)
  (define-key *cl-mode-map* #\TAB 'lisp-indent-line)
  )

(defvar *cl-process* nil)
(defvar *cl-process-open-hook* 'cl-default-open-hook)
(defvar *cl-process-close-hook* nil)
(defvar *cl-process-send-filter* 'cl-default-send-filter)
(defvar *cl-process-read-filter* 'cl-default-read-filter)

(defvar *cl-run-command* nil)
(defvar *cl-run-pop-to-args* nil)
(defvar *cl-keyword-hash-table* nil)
(defvar *cl-keyword-file* "cl")
(defvar *cl-mode-scratch-buffer* "*cl scratch*")

(defun cl-default-send-filter (proc sexp)
  (format nil "~A\r\n" sexp))

(defun cl-default-read-filter (proc text)
  (when *cl-run-pop-to-args*
    (unless (find-buffer (car *cl-run-pop-to-args*))
      (save-excursion
        (switch-to-buffer (car *cl-run-pop-to-args*))
        (setup-temp-buffer (selected-buffer))))
    (apply 'pop-to-buffer *cl-run-pop-to-args*))
  (insert text)
  (set-window (get-buffer-window (process-buffer proc)))
  (refresh-screen))

(defun cl-default-open-hook (buffer)
  (set-buffer buffer)
  (make-process *cl-run-command*))

(defun cl-open-process ()
  (interactive)
  (when (null *cl-process*)
    (let* ((process (funcall *cl-process-open-hook* (selected-buffer))))
      (setf *cl-process* process)
      (when *cl-process*
        (set-process-sentinel
         *cl-process*
         #'(lambda (proc)
             (when *cl-process-close-hook*
               (funcall *cl-process-close-hook* proc))
             (setf *cl-process* nil)))
        (set-process-filter *cl-process* *cl-process-read-filter*))))
  *cl-process*)

(defun cl-eval-string (sexp)
  (when sexp
    (let ((process (cl-open-process)))
      (when process
        (process-send-string process (funcall *cl-process-send-filter* process sexp))))))

(defun cl-eval-current-buffer ()
  (interactive)
  (let* ((text (buffer-substring (point-min) (point-max))))
    (when (and text (> (length text) 0))
      (cl-eval-string text))))

(defun cl-eval-last-sexp()
  (interactive)
  (save-excursion
    (let* ((p (point))
           (s (progn (backward-sexp) (point)))
           (e (progn (forward-sexp) (point)))
           (text (buffer-substring s e)))
      (goto-char p)
      (when (and text (> (length text) 0))
        (cl-eval-string text)))))

(defvar *cl-mode-abbrev-table* nil)
(unless *cl-mode-abbrev-table*
  (define-abbrev-table '*cl-mode-abbrev-table*))

; completion
(defvar *cl-completion-list* nil)
(defun cl-completion ()
  (interactive)
  (or *cl-completion-list*
      (setq *cl-completion-list*
            (make-list-from-keyword-table *cl-keyword-hash-table*))
      (return-from cl-completion nil))
  (let ((opoint (point)))
    (when (skip-syntax-spec-backward "w_")
      (let ((from (point)))
        (goto-char opoint)
        (do-completion from opoint :list *cl-completion-list*)))))

(defvar *cl-mode-hook* nil)
(defun cl-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "CL")
  (setq buffer-mode 'cl-mode)
  (use-keymap *cl-mode-map*)
  (use-syntax-table *lisp-mode-syntax-table*)
  (and *cl-keyword-file*
       (null *cl-keyword-hash-table*)
       (setq *cl-keyword-hash-table*
             (load-keyword-file *cl-keyword-file* t)))
  (when *cl-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *cl-keyword-hash-table*))
  (when *cl-mode-abbrev-table*
    (setq *local-abbrev-table* *cl-mode-abbrev-table*))
  (run-hooks '*cl-mode-hook*))

(defun make-cl-scratch ()
  (interactive)
  (switch-to-buffer *cl-mode-scratch-buffer*)
  (cl-mode)
  (make-local-variable 'need-not-save)
  (setf need-not-save t)
  (make-local-variable 'auto-save)
  (setf auto-save nil))

;;; cl-mode.l ends here
