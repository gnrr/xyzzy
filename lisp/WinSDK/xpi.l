;;;; xpi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows")
  (unless (find-package "xpi")
    (defpackage "xpi" (:use "lisp" "foreign" "winapi"))))

(in-package "xpi")

(include "WinSDK/api/Windows")

;;; xpi.h
(provide "WinSDK/xpi")

(*define XPIS_LEFT    0)
(*define XPIS_TOP     1)
(*define XPIS_RIGHT   2)
(*define XPIS_BOTTOM  3)
(*define XPIS_NOMOVE  4)
(*define XPIS_POSMASK 7)
(*define XPIS_ORDMASK #x30)
(*define XPIS_OUTSIDE #x10)
(*define XPIS_INSIDE  #x20)
(*define XPIS_NOORDER #x30)
(*define XPIS_GROUP   #x40)

(*define-c-type HANDLE XPIHANDLE)

;;; xpi.cc
(defvar xpi_procs 0)
(defvar xpi_nprocs 0)

(*define XPICREATEPANE  0)
(*define XPISETPANESIZE 1)
(*define XPISETPANEPOS  2)

(*defun-c-callable
 BOOL xpiInit (((void *) arg))
 (setf xpi_procs arg
       xpi_nprocs 0)
 (if (zerop xpi_procs)
     (return-from xpiInit 0))
 (while (not (zerop (c-type-chunk-value
		     (make-c-type-chunk FARPROC 1 nil
					(+ xpi_procs (* (sizeof FARPROC) xpi_nprocs))))))
   (incf xpi_nprocs))
 1)

(*define-c-macro
 XPI_CALL (ORD ERR RETTYPE ARGTYPE ARGS)
 `(if (>= xpi_nprocs ,ORD)
      (call-c-proc-address ,RETTYPE ,ARGTYPE
			   (c-type-chunk-value
			    (make-c-type-chunk FARPROC 1 nil
					       (+ xpi_procs
						  (* (sizeof FARPROC) ,ORD))))
			   ,ARGS)
      ,ERR))

(*defun-c-callable
 XPIHANDLE xpiCreatePane ((HWND hwnd) (int cx) (int cy) (DWORD flags))
 (XPI_CALL XPICREATEPANE 0 XPIHANDLE
	   (HWND int int DWORD)
	   (hwnd cx cy flags)))

(*defun-c-callable
 BOOL xpiSetPaneSize ((XPIHANDLE h) (int size) (int min) (int max) (int step))
 (XPI_CALL XPISETPANESIZE 0 BOOL
	   (XPIHANDLE int int int int)
	   (h size min max step)))

(*defun-c-callable
 BOOL xpiSetPanePos ((XPIHANDLE h) (DWORD flags))
 (XPI_CALL XPISETPANEPOS 0 BOOL
	   (XPIHANDLE DWORD)
	   (h flags)))
