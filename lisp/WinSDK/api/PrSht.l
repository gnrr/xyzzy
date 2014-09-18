;;;; PrSht.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/PrSht")

(*define-c-function SNDMSG SendMessage)
