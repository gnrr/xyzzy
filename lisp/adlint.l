;;;
;;; adlint.l
;;;
(require "browserex")
(provide "adlint")

(export '(*adlint-mode-map* *adlint-mode*))
(defvar *adlint-buf-name* "*adlint*")

;;
;; keymap
;;
(defvar *adlint-mode-map* nil)
(unless *adlint-mode-map*
  (setq *adlint-mode-map* (make-sparse-keymap))
  (define-key *adlint-mode-map* '(#\C-x #\k)   'adlint-kill-buffer)
  (define-key *adlint-mode-map* #\RET          'adlint-action-key-enter)
  (define-key *adlint-mode-map* #\r            'revert-buffer))

;;
;; util
;;
(defun adlint-get-current-line ()
  (save-excursion
    (let ((beg (progn (goto-bol) (point)))
          (end (progn (goto-eol) (point))))
      (buffer-substring beg end))))

(defun color-line (ln)
  (save-excursion
    (goto-line ln)
    (delete-text-attributes 'mk)
    (set-text-attribute (progn (beginning-of-line) (point))
                        (progn (end-of-line) (point))
                        'mk
                        :background 3)))

(defun adlint-refer-messages (num)
  (interactive)
  (let ((uri "file://C:/Ruby193/lib/ruby/gems/1.9.1/gems/adlint-3.2.14/share/doc/users_guide_ja.html"))
;;(let ((uri "http://adlint.sourceforge.net/pmwiki/upload.d/Main/users_guide_ja.html"))
    (bx:navigate (concat uri "#" num))))

(defun adlint-find-file ()
  (let* ((line (adlint-get-current-line))
         (fn   (nth 1 (split-string line #\, t)))
         (row  (parse-integer (nth 2 (split-string line #\, t))))
         (col  (parse-integer (nth 3 (split-string line #\, t))))
         (mnum (nth 5 (split-string line #\, t))))
      (if (file-exist-p fn)
          (progn
            (let ((*find-file-hooks* #'(lambda () (view-mode t))))
              (color-line (current-line-number))
              (find-file-other-window fn)
              (goto-line row)
              (beginning-of-line)
              (forward-char (1- col))
              (adlint-refer-messages mnum)
              ))
        (message (concat "not found: " fn)))))

(defun adlint-kill-buffer ()
  (interactive)
  (bx:close-browser)
  (kill-buffer (selected-buffer)))
;;
;; command
;;
(defun adlint-action-key-enter ()
  (interactive)
  (adlint-find-file))

(defun adlint ()
  (interactive)
  (set-buffer-modified-p nil)
  ;; (setq buffer-read-only t)
  (adlint-mode)
  (view-mode t))

(defun adlint-mode ()
  ;(kill-all-local-variables)
  (setq buffer-mode 'adlint-mode)
  (setq mode-name "adlint")
  (use-keymap *adlint-mode-map*)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information t)
  ;(make-local-variable 'highlight-keyword)
  ;(setq highlight-keyword nil)
  (run-hooks '*adlint-mode-hook*))

;;; adlint.l ends here
