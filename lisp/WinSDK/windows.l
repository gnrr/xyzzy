(provide "WinSDK/windows")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/foreign")
  (require "api")
  (require "treeview/winapi"))
