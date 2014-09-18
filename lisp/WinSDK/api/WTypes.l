;;;; WTypes.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(include "WinSDK/api/Rpc")

(provide "WinSDK/api/WTypes")

#| header files for imported files |#
(include "WinSDK/api/BaseTsd")
(include "WinSDK/api/Guiddef")

(*define-c-type WCHAR       OLECHAR)

(*define-c-type (OLECHAR *) LPOLESTR)

(*define-c-enum
 DVASPECT
 (DVASPECT_CONTENT   1)
 (DVASPECT_THUMBNAIL 2)
 (DVASPECT_ICON      4)
 (DVASPECT_DOCPRINT  8))

(*define-c-type WORD        CLIPFORMAT)

(*define-c-type (void *)    HMETAFILEPICT)
