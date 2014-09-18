;;;; WinBase.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/WinBase")

(*define INVALID_HANDLE_VALUE     #xFFFFFFFF)
(*define INVALID_FILE_SIZE        (DWORD #xFFFFFFFF))
(*define INVALID_SET_FILE_POINTER (DWORD -1))
(*define INVALID_FILE_ATTRIBUTES  (DWORD -1))

(*define FILE_BEGIN               0)
(*define FILE_CURRENT             1)
(*define FILE_END                 2)

(*define-c-type (SECURITY_ATTRIBUTES *) LPSECURITY_ATTRIBUTES)

#| Global Memory Flags |#
(*define GMEM_FIXED          #x0000)
(*define GMEM_MOVEABLE       #x0002)
(*define GMEM_NOCOMPACT      #x0010)
(*define GMEM_NODISCARD      #x0020)
(*define GMEM_ZEROINIT       #x0040)
(*define GMEM_MODIFY         #x0080)
(*define GMEM_DISCARDABLE    #x0100)
(*define GMEM_NOT_BANKED     #x1000)
(*define GMEM_SHARE          #x2000)
(*define GMEM_DDESHARE       #x2000)
(*define GMEM_NOTIFY         #x4000)
(*define GMEM_LOWER          GMEM_NOT_BANKED)
(*define GMEM_VALID_FLAGS    #x7F72)
(*define GMEM_INVALID_HANDLE #x8000)

(*define GHND                (logior GMEM_MOVEABLE GMEM_ZEROINIT))
(*define GPTR                (logior GMEM_FIXED GMEM_ZEROINIT))

(*define FS_CASE_IS_PRESERVED            FILE_CASE_PRESERVED_NAMES)
(*define FS_CASE_SENSITIVE               FILE_CASE_SENSITIVE_SEARCH)
(*define FS_UNICODE_STORED_ON_DISK       FILE_UNICODE_ON_DISK)
(*define FS_PERSISTENT_ACLS              FILE_PERSISTENT_ACLS)
(*define FS_VOL_IS_COMPRESSED            FILE_VOLUME_IS_COMPRESSED)
(*define FS_FILE_COMPRESSION             FILE_FILE_COMPRESSION)
(*define FS_FILE_ENCRYPTION              FILE_SUPPORTS_ENCRYPTION)

(*define-dll-entry
 HGLOBAL GlobalAlloc (UINT SIZE_T) "kernel32")

(*define-dll-entry
 DWORD GlobalSize (HGLOBAL) "kernel32")

(*define-dll-entry
 LPVOID GlobalLock (HGLOBAL) "kernel32")

(*define-dll-entry
 BOOL GlobalUnlock (HGLOBAL) "kernel32")

(*define-dll-entry
 HLOCAL LocalFree (HLOCAL) "kernel32")

(*define-dll-entry
 DWORD GetLastError () "kernel32")

(*define-dll-entry
 DWORD GetFileSize (HANDLE LPDWORD) "kernel32")

(*define-dll-entry
 DWORD SetFilePointer (HANDLE LONG PLONG DWORD) "kernel32")

(*define-dll-entry
 DWORD FormatMessageA (DWORD LPCVOID DWORD DWORD LPSTR DWORD (va_list *)) "kernel32")
(*define-dll-entry
 DWORD FormatMessageW (DWORD LPCVOID DWORD DWORD LPWSTR DWORD (va_list *)) "kernel32")

(*define FORMAT_MESSAGE_ALLOCATE_BUFFER #x00000100)
(*define FORMAT_MESSAGE_IGNORE_INSERTS  #x00000200)
(*define FORMAT_MESSAGE_FROM_STRING     #x00000400)
(*define FORMAT_MESSAGE_FROM_HMODULE    #x00000800)
(*define FORMAT_MESSAGE_FROM_SYSTEM     #x00001000)
(*define FORMAT_MESSAGE_ARGUMENT_ARRAY  #x00002000)
(*define FORMAT_MESSAGE_MAX_WIDTH_MASK  #x000000FF)

(*define-dll-entry
 HANDLE CreateFileA (LPCSTR DWORD DWORD LPSECURITY_ATTRIBUTES DWORD DWORD HANDLE) "kernel32")
(*define-dll-entry
 HANDLE CreateFileW (LPCWSTR DWORD DWORD LPSECURITY_ATTRIBUTES DWORD DWORD HANDLE) "kernel32")

(*define-dll-entry
 BOOL GetVolumeInformationA (LPCSTR LPSTR DWORD LPDWORD LPDWORD LPDWORD LPSTR DWORD) "kernel32")
(*define-dll-entry
 BOOL GetVolumeInformationW (LPCWSTR LPWSTR DWORD LPDWORD LPDWORD LPDWORD LPWSTR DWORD) "kernel32")

(include "WinSDK/api/WinError")
