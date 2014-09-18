;;;; OleIdl.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(include "WinSDK/api/Rpc")

;#ifndef COM_NO_WINDOWS_H
(include "WinSDK/api/Windows")
(include "WinSDK/api/Ole2")
;#endif /*COM_NO_WINDOWS_H*/

(provide "WinSDK/api/OleIdl")

(include "WinSDK/api/ObjIdl")

(*define MK_ALT             #x20)
(*define DROPEFFECT_NONE    0)
(*define DROPEFFECT_COPY    1)
(*define DROPEFFECT_MOVE    2)
(*define DROPEFFECT_LINK    4)
(*define DROPEFFECT_SCROLL  #x80000000)
