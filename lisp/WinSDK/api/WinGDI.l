;;;; WinGDI.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/WinGDI")

(*define ETO_OPAQUE              #x0002)
(*define ETO_CLIPPED             #x0004)
(c-if (>= (ed:os-major-version) 4)
  (progn
    (*define ETO_GLYPH_INDEX     #x0010)
    (*define ETO_RTLREADING      #x0080)
    (*define ETO_NUMERICSLOCAL   #x0400)
    (*define ETO_NUMERICSLATIN   #x0800)
    (*define ETO_IGNORELANGUAGE  #x1000)))
(c-if (>= (ed:os-major-version) 5)
  (*define ETO_PDY               #x2000))
(c-if (>= (ed:os-major-version) 6)
  (*define ETO_REVERSE_INDEX_MAP #x10000))

;; Background Modes
(*define TRANSPARENT 1)
(*define OPAQUE      2)
(*define BKMODE_LAST 2)

(*define-dll-entry
 COLORREF SetBkColor (HDC COLORREF) "gdi32")

(*define-dll-entry
 int SetBkMode (HDC int) "gdi32")
