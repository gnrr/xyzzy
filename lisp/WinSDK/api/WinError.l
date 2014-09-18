;;;; WinError.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/WinError")

;;
;; MessageId: ERROR_SUCCESS
;;
;; MessageText:
;;
;; The operation completed successfully.
;;
(*define ERROR_SUCCESS 0)

(*define NO_ERROR      0) ; dderror
(*define SEC_E_OK      0)

;;
;; Generic test for success on any status value (non-negative numbers
;; indicate success).
;;
(*define-c-macro SUCCEEDED (hr)
		 `(>= ,hr 0))

;;
;; and the inverse
;;
(*define-c-macro FAILED (hr)
		 `(< ,hr 0))

(*define-c-type long        HRESULT)

;;
;; Success codes
;;
(*define S_OK               0)
(*define S_FALSE            1)
