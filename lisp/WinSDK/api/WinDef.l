;;;; WinDef.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/WinDef")

(*define MAX_PATH 260)

(*define NULL     0)

(*define-c-type u_long    DWORD)
(*define-c-type int       BOOL)
(*define-c-type u_char    BYTE)
(*define-c-type u_short   WORD)
(*define-c-type float     FLOAT)
(*define-c-type (FLOAT *) PFLOAT)
(*define-c-type (BOOL *)  PBOOL)
(*define-c-type (BOOL *)  LPBOOL)
(*define-c-type (BYTE *)  PBYTE)
(*define-c-type (BYTE *)  LPBYTE)
(*define-c-type (int *)   PINT)
(*define-c-type (int *)   LPINT)
(*define-c-type (WORD *)  PWORD)
(*define-c-type (WORD *)  LPWORD)
(*define-c-type (long *)  LPLONG)
(*define-c-type (DWORD *) PDWORD)
(*define-c-type (DWORD *) LPDWORD)
(*define-c-type (void *)  LPVOID)
(*define-c-type (void *)  LPCVOID)

(include "WinSDK/api/WinNT")

(*define-c-macro MAKEWORD (a b) `(logior (logand ,a #xff) (ash (logand ,b #xff) 8)))
(*define-c-macro MAKELONG (a b) `(logior (logand ,a #xffff) (ash (logand ,b #xffff) 16)))
(*define-c-macro LOWORD (l)     `(logand ,l #xffff))
(*define-c-macro HIWORD (l)     `(logand (ash ,l -16) #xffff))
(*define-c-macro LOBYTE (w)     `(logand ,w #xff))
(*define-c-macro HIBYTE (w)     `(logand (ash ,w -8) #xff))

(*define-c-type (POINT *) LPPOINT)

(*define-c-struct
 POINTL
 (LONG x)
 (LONG y))
(*define-c-type (POINTL *) PPOINTL)

(*define-c-type SIZE SIZEL)

(*define-c-struct
 FILETIME
 (DWORD dwLowDateTime)
 (DWORD dwHighDateTime))
(*define-c-type (FILETIME *) PFILETIME)
(*define-c-type (FILETIME *) LPFILETIME)
