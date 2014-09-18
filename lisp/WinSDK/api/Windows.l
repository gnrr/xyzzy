;;;; Windows.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/Windows")

(include "WinSDK/c/excpt")

(include "WinSDK/api/WinDef")
(include "WinSDK/api/WinBase")
(include "WinSDK/api/WinGDI")
(include "WinSDK/api/WinUser")

(include "WinSDK/api/Rpc")
(include "WinSDK/api/ShellAPI")

(include "WinSDK/api/WinSCard")

(include "WinSDK/api/Ole2")
