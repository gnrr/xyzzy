;;;; Ole2.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/Ole2")

(include "WinSDK/api/WinError")

(include "WinSDK/api/ObjBase")

(include "WinSDK/api/OleIdl")

#| Drag/Drop APIs |#
(*define-dll-entry
 WINOLEAPI RegisterDragDrop (HWND (void #|IDropTarget|# *)) "ole32")
(*define-dll-entry
 WINOLEAPI RevokeDragDrop (HWND) "ole32")
(*define-dll-entry
 WINOLEAPI DoDragDrop ((void #|IDataObject|# *) (void #|IDropSource|# *) DWORD (DWORD *)) "ole32")

(*define-dll-entry
 void ReleaseStgMedium ((STGMEDIUM *)) "ole32")
