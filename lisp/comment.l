;;; comment.l

;; Ported to xyzzy by kia <meshinsha@yahoo.co.jp> : 2003-05-19

;; For xyzzy users, put it somewhere in your load path and add the
;; following lines to your .xyzzy:
;;
;;           (autoload 'comment-out-region "comment" t nil)
;;           (global-set-key '(#\C-c #\q) 'comment-out-region)


;;; comment.el --- comment out regions of buffers

;; Copyright (C) 1995 Noah S. Friedman

;; Author: Noah Friedman <friedman@splode.com>
;; Maintainer: friedman@splode.com
;; Keywords: extensions
;; Created: 1995-02-10

;; $Id: comment.el,v 1.9 2001/02/19 21:48:35 friedman Exp $

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 675 Massachusetts Avenue; Cambridge, MA 02139, USA.

;;; Commentary:

;; This program provides a mode-sensitive command for commenting out
;; regions of program text.  It can also be used to quote regions of mail
;; messages.

;; To use this, put it somewhere in your load path and add the following
;; lines to your .emacs:
;;
;;          (autoload 'comment-out-region "comment" nil t)
;;          (global-set-key "\C-cq" 'comment-out-region)
;;
;; With this binding, you can reverse the action (i.e uncomment) a
;; region by supplying a universal prefix argument, i.e. `C-u C-c q'.

;;; Code:

(provide "comment")
(in-package "user")

;;;###autoload
(defvar comment-mode-alist
  '((t                         #\#   1         " ")
    (ed::basic-mode            "' ")
    (ed::c++-mode              "// ")
    ;(ed::c-mode                nil   "#if 0\n" "\n#endif")
    ;(ed::c-mode                nil   "/*\n"    "\n*/")
    (ed::c-mode                " * " "/* "     "\n */")
    (ed::csharp-mode           "//// ")
    (ed::css-mode              " * " "/* "     "\n */")
    ;(ed::java-mode             " * " "/**\n"   "\n */")
    (ed::java-mode             "// ")
    (ed::html-mode             nil   "<!--\n"  "\n-->")
    (ed::idl-mode              "// ")
    (ed::LaTeX-mode            #\%   1         " ")
    (ed::lisp-interaction-mode #\;   2         " ")
    (ed::lisp-mode             #\;   2         " ")
    ;(ed::pascal-mode          nil   "(*\n"    "\n*)")
    (ed::pascal-mode           " * " "(* "     "\n *)")
    (ed::perl-mode             #\#   1         " ")
    (ed::sql-mode              "-- ")
    (ed::text-mode             #\#   1         " ")
    (ed::html+-mode            nil   "<!--\n"  "\n-->")
    (ed::jscript-mode          "// ")
    (ed::php-mode              "// ")
    (ed::ruby-mode             #\#   1         " ")
    )
  "Association between major mode and types of comment characters.
This variable is a list of lists; each list consists of a major mode
and one of two possible sets of values:

* If the first value is nil or a string, the arguments are as follows:

If only one string is specified, that string is inserted in front of
every line in the region.

If a second string is specified, it is the \"begin comment\" string.
For example, in C a comment begins with \"/*\".  The first string, if
non-`nil', will be inserted before the rest of the lines.

If a third string is specified, it is the \"end comment\" string.  For
example, in C a comment ends with \"*/\".  The first and second
strings, if non-`nil', will be inserted before the middle and first
lines, respectively.

* If the first value is a single character in numeric form, the
arguments are as follows:

The first value is the character to insert in front of every line.

The second value, if non-`nil', is the default number of times to
insert that character on each line, if no prefix argument is specified.
This value defaults to 1 if unspecified.

The third value, if non-`nil' means to insert that char or string
after the inserted comment character(s).  Usually it will be a space or
empty.

If no entry for a particuar mode exists, the values of `comment-start' and
`comment-end' are used if they exist and contain useful values \(e.g. not
\"\"\).  These are standard variables in some versions of Emacs 19.

Otherwise, the characters specified in this alist with the key `t' are
used.  This key should be kept as close to the beginning of the alist as
possible to minimize searching for it.")

(defvar *comment-trim-right-spaces* t)


;;;###autoload
(defun comment-out-region (&optional beg end count)
  "Comment or uncomment a region of text according to major mode.

This command, when called with no prefix argument or a positive numeric
prefix argument, puts comments characters appropriate to the current major
mode in front of (or around) the lines of the region delimited by point and
mark.

If called with a generic prefix argument or with a negative numeric prefix
argument, attempt to remove the comments in front of the text in the
region.

When called from lisp programs, this function takes 3 optional arguments:
the beginning and end of the region to comment, and a count which
determines whether to add or remove comments depending on whether it is nil
\(like specifying no prefix arg\), positive, or negative.

Mode-specific comment characters are defined in the table
`comment-mode-alist'."
  (interactive "r\np")
  (or beg (setq beg (point)))
  (or end (setq end (mark)))
  (let ((fn (cond ((eq *prefix-args* 'universal-argument)
                   (setq count (list count))
                   'comment-do-uncomment)
                  ((and (numberp count)
                        (> 0 count))
                   'comment-do-uncomment)
                  (t
                   'comment-do-comment))))
    (funcall fn beg end count)))

(defun comment-do-comment (region-begin region-end count)
  (let* ((data (match-data))
         (list (or (comment-assq buffer-mode comment-mode-alist)
                   (comment-mode-specific-comment-chars)
                   (comment-assq t comment-mode-alist)))
         (std (nth 1 list))
         (beg (nth 2 list))
         (end (nth 3 list)))

    (cond ((or (stringp std)
               (null std)))
          (t
           (cond
            ((null count)
             (setq count (or beg 1)))
            ((consp count)
             (setq count (car count))))

           (setq std (comment-make-string count std))
           (and end
                (setq std (concat std end)))
           (setq beg nil)
           (setq end nil)))

    (save-excursion
      (save-restriction
        (widen)
        (narrow-to-region region-begin region-end)
        (goto-char (point-max))
        (and (bolp)
             (> (point-max) (point-min))
             (narrow-to-region (point-min) (1- (point-max))))

        (goto-char (point-min))
        (and beg (comment-insert beg))

        (and std
             (while (scan-buffer "^" :regexp t :limit (point-max) :tail t)
               (comment-insert std)))

        (and end
             (progn
               (goto-char (point-max))
               (comment-insert end)))))
    (store-match-data data)))

(defun comment-do-uncomment (region-begin region-end count)
  (let* ((data (match-data))
         (list (or (comment-assq buffer-mode comment-mode-alist)
                   (comment-mode-specific-comment-chars)
                   (comment-assq t comment-mode-alist)))
         (std (nth 1 list))
         (beg (nth 2 list))
         (end (nth 3 list))
         len)
    (cond ((or (comment-character-p std)
               (and (stringp std)
                    (null beg)
                    (null end)))
           (cond ((comment-character-p std)
                  (cond ((consp count)
                         (setq count (car count)))
                        ((or (null count)
                             (zerop count))
                         (setq count (or beg 1))))
                  (setq count (abs count))
                  (setq std (concat
                             (format nil "^\\s *\\([~c]\\)" std)
                             (comment-mapconcat 'identity
                                                (make-list (1- count) :initial-element "\\1?")
                                                "")))
                  (setq len (length end))
                  (and end (setq end (regexp-quote end))))
                 (t
                  (setq std (concat "^" (comment-regexp-quote std)))))
           (save-excursion
             (save-restriction
               (widen)
               (narrow-to-region region-begin region-end)
               (goto-char (point-min))
               (while (scan-buffer std :regexp t :limit (point-max) :tail t)
                 (delete-region (match-beginning 0) (match-end 0))
                 (and end
                      (looking-at end)
                      (delete-char len))
                 (and (bolp)
                      (/= (point) (point-max))
                      (forward-char 1))))))

          (t
           (let ((stdq (and std (concat "^" (comment-regexp-quote std))))
                 ;; These are not made to match the beginning of a line
                 ;; since they may contain embedded newlines.
                 (begq (and beg (comment-regexp-quote beg)))
                 (endq (and end (regexp-quote end))))
             (save-excursion
               (save-restriction
                 (widen)
                 (narrow-to-region region-begin region-end)
                 (goto-char (point-max))
                 (and endq
                      (progn
                        (or (scan-buffer endq :regexp t :reverse t :limit (point-min) :tail nil)
                            (error "region doesn't contain comment end."))
                        (delete-region (match-beginning 0)
                                       (match-end 0))))
                 (goto-char (point-min))
                 (and beg
                      (not (or (looking-at begq)
                               (scan-buffer begq :regexp t :limit (point-max) :tail t)))
                      (error "region doesn't contain comment start."))
                 (delete-char (length beg))
                 (and stdq
                      (while (scan-buffer stdq :regexp t :limit (point-max) :tail t)
                        (delete-region (match-beginning 0) (match-end 0))
                        (and (bolp)
                             (/= (point) (point-max))
                             (forward-char 1)))))))))
    (store-match-data data)))

;; Try to find comment chars from emacs mode defaults,
;; if they exist and are useful.
(defun comment-mode-specific-comment-chars ()
  (let ((b (cond ((or (not (boundp 'comment-start))
                      (null comment-start)
                      (equal comment-start ""))
                  nil)
                 (t comment-start)))
        (e (cond ((or (not (boundp 'comment-end))
                      (null comment-end)
                      (equal comment-end ""))
                  nil)
                 (t comment-end))))
    (cond ((not (or b e))
           nil)
          ((and b (not e))
           (if (= (length b) 1)
               ;; This is a more useful form for a single char.
               (list 'default (comment-string-to-char b) 1)
             (list 'default b)))
          (t
           (list 'default nil b e)))))

(defun comment-character-p (obj)
  ;; In XEmacs 20.x, characters are a distinct type.
  (if (fboundp 'characterp)
      (characterp obj)
    (integerp obj)))

(defun comment-assq (item alist)
  (assoc item alist :test #'eq))

(defun comment-make-string (count character)
  (make-sequence 'string count :initial-element character))

(defun comment-mapconcat (func seq sep)
  (apply #'concatenate
         (cons 'string
               (reduce #'(lambda (x y) (if (consp y) `(,x ,sep ,@y) `(,x ,sep ,y)))
                       (mapcar func (concatenate 'list seq))
                       :from-end t))))

(defun comment-string-to-char (str)
  (if (string= str "")
      #\NUL
    (schar str 0)))

(setf (symbol-function 'comment-trim-right-spaces)
      (let (src trimmed)
        #'(lambda (s)
            (if (string= src s)
                trimmed
              (setq src s trimmed (string-right-trim " \t" s))))))

(defun comment-insert (s)
  (if (and *comment-trim-right-spaces* (eolp))
      (insert (comment-trim-right-spaces s))
    (insert s)))

(defun comment-regexp-quote (s)
  (if (string-match "[ \t]+$" s)
      (format nil "~A~A" (regexp-quote (string-right-trim " \t" s)) (format nil "\\(:?~A\\)?" (match-string 0)))
    (regexp-quote s)))

(defvar *comment-after-load-hook* nil)
(run-hooks '*comment-after-load-hook*)

;;; comment.l ends here
