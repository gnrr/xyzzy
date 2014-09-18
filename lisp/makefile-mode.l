;;
;; http://raido.sakura.ne.jp/southly/xyzzy/makefile-mode.l
;;
(provide "makefile-mode")

(in-package "editor")

(export '(makefile-mode
         *makefile-mode-hook*))

(defvar *makefile-mode-hook* nil)

(defvar *makefile-mode-map* nil)
(unless *makefile-mode-map*
 (setq *makefile-mode-map* (make-sparse-keymap)))

(defvar *makefile-mode-syntax-table* nil)
(unless *makefile-mode-syntax-table*
 (setq *makefile-mode-syntax-table* (make-syntax-table))
 (set-syntax-start-comment *makefile-mode-syntax-table* #\# t)
 (set-syntax-end-comment *makefile-mode-syntax-table* #\LFD nil t))

(defvar *makefile-regexp-keyword-list* nil)
(setq *makefile-regexp-keyword-list*
     (compile-regexp-keyword-list
      '(("^\t+\\([+---@]+\\)" nil (:keyword 1 :bold) nil 1 1)
        ("^ *\\(\\.DEFAULT\\|\\.DELETE_ON_ERROR\\|\\.EXPORT_ALL_VARIABLES\\|\\.IGNORE\\|\\.INTERMEDIATE\\|\\.PHONY\\|\\.POSIX\\|\\.PRECIOUS\\|\\.SECONDARY\\|\\.SILENT\\|\\.SUFFIXES\\)[ \t]*:"
         nil (:keyword 0 :underline) nil 1 1)
        ("^ *\\(define\\|endef\\|ifdef\\|ifndef\\|ifeq\\|ifneq\\|else\\|endif\\|include\\|override\\|export\\|unexport\\|vpath\\)\\b"
         nil (:keyword 2) nil 1 1)
        ("\\$%\\|\\$(%D)\\|\\$(%F)\\|\\$(\\*D)\\|\\$(\\*F)\\|\\$(<D)\\|\\$(<F)\\|\\$(\\?D)\\|\\$(\\?F)\\|\\$(@D)\\|\\$(@F)\\|\\$(\\^D)\\|\\$(\\^F)\\|\\$\\*\\|\\$\\+\\|\\$<\\|\\$\\?\\|\\$@\\|\\$\\^"
         nil (:color 1 0) nil 0 0)
        ))
     )

(defun makefile-mode ()
 (interactive)
 (kill-all-local-variables)
 (setq buffer-mode 'makefile-mode)
 (setq mode-name "Makefile")
 (use-keymap *makefile-mode-map*)
 (use-syntax-table *makefile-mode-syntax-table*)
 (make-local-variable 'regexp-keyword-list)
 (setq regexp-keyword-list *makefile-regexp-keyword-list*)
 (run-hooks '*makefile-mode-hook*))


#|
.DEFAULT
.DELETE_ON_ERROR
.EXPORT_ALL_VARIABLES
.IGNORE
.INTERMEDIATE
.PHONY
.POSIX
.PRECIOUS
.SECONDARY
.SILENT
.SUFFIXES

define
endef

ifdef
ifndef
ifeq
ifneq
else
endif

include
override
export
unexport
vpath

+
-
@

$%
$(%D)
$(%F)
$(*D)
$(*F)
$(<D)
$(<F)
$(?D)
$(?F)
$(@D)
$(@F)
$(^D)
$(^F)
$*
$+
$<
$?
$@
$^

|#
