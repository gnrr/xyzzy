;;;; ObjIdl.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(include "WinSDK/api/Rpc")

;#ifndef COM_NO_WINDOWS_H
(include "WinSDK/api/Windows")
(include "WinSDK/api/Ole2")
;#endif /*COM_NO_WINDOWS_H*/

(provide "WinSDK/api/ObjIdl")

(*define-c-struct
 DVTARGETDEVICE
 (DWORD tdSize)
 (WORD  tdDriverNameOffset)
 (WORD  tdDeviceNameOffset)
 (WORD  tdPortNameOffset)
 (WORD  tdExtDevmodeOffset)
 (BYTE  tdData 1))

(*define-c-type (CLIPFORMAT *) LPCLIPFORMAT)

(*define-c-struct
 FORMATETC
 (CLIPFORMAT         cfFormat)
 ((DVTARGETDEVICE *) ptd)
 (DWORD              dwAspect)
 (LONG               lindex)
 (DWORD              tymed))

(*define-c-type (FORMATETC *)  LPFORMATETC)

(*define-c-enum
 TYMED
 (TYMED_HGLOBAL  1)
 (TYMED_FILE     2)
 (TYMED_ISTREAM  4)
 (TYMED_ISTORAGE 8)
 (TYMED_GDI      16)
 (TYMED_MFPICT   32)
 (TYMED_ENHMF    64)
 (TYMED_NULL     0))

(*define-c-union
 STGMEDIUMUNION
 (HBITMAP               hBitmap)
 (HMETAFILEPICT         hMetaFilePict)
 (HENHMETAFILE          hEnhMetaFile)
 (HGLOBAL               hGlobal)
 (LPOLESTR              lpszFileName)
 ((void #|IStream|# *)  pstm)
 ((void #|IStorage|# *) pstg))
(*define-c-struct
 STGMEDIUM
 (DWORD                 tymed)
 (STGMEDIUMUNION        u)
 ((void #|IUnknown|# *) pUnkForRelease))

(*define-c-type STGMEDIUM     ASYNC_STGMEDIUM)

(*define-c-type (STGMEDIUM *) LPSTGMEDIUM)
