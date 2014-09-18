;;;; ShellAPI.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/ShellAPI")

(*define-c-type HANDLE      HDROP)

(*define-dll-entry
 UINT DragQueryFileA (HDROP UINT LPSTR UINT) "shell32")
(*define-dll-entry
 UINT DragQueryFileW (HDROP UINT LPWSTR UINT) "shell32")

(*define-c-struct
 SHFILEINFOA
 (HICON hIcon)                     ; out: icon
 (int   iIcon)                     ; out: icon index
 (DWORD dwAttributes)              ; out: SFGAO_ flags
 (CHAR szDisplayName MAX_PATH)     ; out: display name (or path)
 (CHAR szTypeName 80))             ; out: type name
(*define-c-struct
 SHFILEINFOW
 (HICON hIcon)                     ; out: icon
 (int   iIcon)                     ; out: icon index
 (DWORD dwAttributes)              ; out: SFGAO_ flags
 (WCHAR szDisplayName MAX_PATH)    ; out: display name (or path)
 (WCHAR szTypeName 80))            ; out: type name

(*define SHGFI_ICON              #x000000100)	  ; get icon
(*define SHGFI_DISPLAYNAME       #x000000200)	  ; get display name
(*define SHGFI_TYPENAME          #x000000400)	  ; get type name
(*define SHGFI_ATTRIBUTES        #x000000800)	  ; get attributes
(*define SHGFI_ICONLOCATION      #x000001000)	  ; get icon location
(*define SHGFI_EXETYPE           #x000002000)	  ; return exe type
(*define SHGFI_SYSICONINDEX      #x000004000)	  ; get system icon index
(*define SHGFI_LINKOVERLAY       #x000008000)	  ; put a link overlay on icon
(*define SHGFI_SELECTED          #x000010000)	  ; show icon in selected state
(c-if (>= (ed:os-major-version) 5) ; (NTDDI_VERSION >= NTDDI_WIN2K)
      (*define SHGFI_ATTR_SPECIFIED  #x000020000))  ; get only specified attributes
(*define SHGFI_LARGEICON         #x000000000)	  ; get large icon
(*define SHGFI_SMALLICON         #x000000001)	  ; get small icon
(*define SHGFI_OPENICON          #x000000002)	  ; get open icon
(*define SHGFI_SHELLICONSIZE     #x000000004)	  ; get shell size icon
(*define SHGFI_PIDL              #x000000008)	  ; pszPath is a pidl
(*define SHGFI_USEFILEATTRIBUTES #x000000010)	  ; use passed dwFileAttribute

;#if (_WIN32_IE >= 0x0500)
(*define SHGFI_ADDOVERLAYS       #x000000020)	  ; apply the appropriate overlays
(*define SHGFI_OVERLAYINDEX      #x000000040)	  ; Get the index of the overlay
; in the upper 8 bits of the iIcon
;#endif

(*define-dll-entry
 DWORD_PTR SHGetFileInfoA (LPCSTR DWORD (SHFILEINFOA *) UINT UINT) "shell32")
(*define-dll-entry
 DWORD_PTR SHGetFileInfoW (LPCWSTR DWORD (SHFILEINFOW *) UINT UINT) "shell32")
