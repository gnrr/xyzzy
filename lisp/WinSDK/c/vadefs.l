;;;; vadefs.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/foreign"))

(in-package "foreign")

(provide "WinSDK/c/vadefs")

;#ifndef _VA_LIST_DEFINED
(*define-c-type (char *) va_list)
;#define _VA_LIST_DEFINED
;#endif
