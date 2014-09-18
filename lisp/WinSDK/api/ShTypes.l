;;;; ShTypes.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(include "WinSDK/api/Rpc")

(provide "WinSDK/api/ShTypes")

(*define-c-struct
 SHITEMID
 (USHORT cb)
 (BYTE   abID 1))

(*define-c-struct
 ITEMIDLIST
 (SHITEMID mkid))

(*define-c-type (ITEMIDLIST *) LPITEMIDLIST)
