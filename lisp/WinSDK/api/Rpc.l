;;;; Rpc.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

;#if !defined( RPC_NO_WINDOWS_H ) && !defined( MAC ) && !defined( _MAC ) && !defined(_KRPCENV_)
(include "WinSDK/api/Windows")
;#endif // RPC_NO_WINDOWS_H

(provide "WinSDK/api/Rpc")

(include "WinSDK/api/BaseTsd")
