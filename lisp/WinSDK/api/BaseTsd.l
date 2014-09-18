;;;; BaseTsd.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/BaseTsd")

(*define-c-type u_int  UINT_PTR)
(*define-c-type u_long ULONG_PTR)

(*define-c-type ULONG_PTR     SIZE_T)
(*define-c-type (ULONG_PTR *) PSIZE_T)

(*define-c-type ULONG_PTR   DWORD_PTR)
