;;;; Guiddef.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(*define-c-struct
 GUID
 (u_long  Data1)
 (u_short Data2)
 (u_short Data3)
 (u_char  Data4 8))

(provide "WinSDK/api/Guiddef")

(*define-c-type GUID CLSID)
