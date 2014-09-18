;;;; ObjBase.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(include "WinSDK/api/Rpc")

(provide "WinSDK/api/ObjBase")

(*define-c-type HRESULT     WINOLEAPI)

(include "WinSDK/api/WTypes")
;(include "WinSDK/api/Unknwn")
(include "WinSDK/api/ObjIdl")

(include "WinSDK/api/Guiddef")

(*define-dll-entry
 void CoTaskMemFree ((void *)) "ole32")
