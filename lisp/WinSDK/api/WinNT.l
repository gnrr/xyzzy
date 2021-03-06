;;;; WinNT.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/WinNT")

(include "WinSDK/api/BaseTsd")

(*define-c-type (WCHAR *)   LPCWSTR)
(*define-c-type (WCHAR *)   PCWSTR)

(*define-c-type (SHORT *)   PSHORT)
(*define-c-type (LONG *)    PLONG)

(include "WinSDK/api/Guiddef")

(*define FILE_SHARE_READ                     #x00000001)
(*define FILE_SHARE_WRITE                    #x00000002)
(*define FILE_SHARE_DELETE                   #x00000004)
(*define FILE_ATTRIBUTE_READONLY             #x00000001)
(*define FILE_ATTRIBUTE_HIDDEN               #x00000002)
(*define FILE_ATTRIBUTE_SYSTEM               #x00000004)
(*define FILE_ATTRIBUTE_DIRECTORY            #x00000010)
(*define FILE_ATTRIBUTE_ARCHIVE              #x00000020)
(*define FILE_ATTRIBUTE_DEVICE               #x00000040)
(*define FILE_ATTRIBUTE_NORMAL               #x00000080)
(*define FILE_ATTRIBUTE_TEMPORARY            #x00000100)
(*define FILE_ATTRIBUTE_SPARSE_FILE          #x00000200)
(*define FILE_ATTRIBUTE_REPARSE_POINT        #x00000400)
(*define FILE_ATTRIBUTE_COMPRESSED           #x00000800)
(*define FILE_ATTRIBUTE_OFFLINE              #x00001000)
(*define FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  #x00002000)
(*define FILE_ATTRIBUTE_ENCRYPTED            #x00004000)
(*define FILE_ATTRIBUTE_VIRTUAL              #x00010000)
(*define FILE_NOTIFY_CHANGE_FILE_NAME        #x00000001)
(*define FILE_NOTIFY_CHANGE_DIR_NAME         #x00000002)
(*define FILE_NOTIFY_CHANGE_ATTRIBUTES       #x00000004)
(*define FILE_NOTIFY_CHANGE_SIZE             #x00000008)
(*define FILE_NOTIFY_CHANGE_LAST_WRITE       #x00000010)
(*define FILE_NOTIFY_CHANGE_LAST_ACCESS      #x00000020)
(*define FILE_NOTIFY_CHANGE_CREATION         #x00000040)
(*define FILE_NOTIFY_CHANGE_SECURITY         #x00000100)
(*define FILE_ACTION_ADDED                   #x00000001)
(*define FILE_ACTION_REMOVED                 #x00000002)
(*define FILE_ACTION_MODIFIED                #x00000003)
(*define FILE_ACTION_RENAMED_OLD_NAME        #x00000004)
(*define FILE_ACTION_RENAMED_NEW_NAME        #x00000005)
(*define MAILSLOT_NO_MESSAGE                 (DWORD -1))
(*define MAILSLOT_WAIT_FOREVER               (DWORD -1))
(*define FILE_CASE_SENSITIVE_SEARCH          #x00000001)
(*define FILE_CASE_PRESERVED_NAMES           #x00000002)
(*define FILE_UNICODE_ON_DISK                #x00000004)
(*define FILE_PERSISTENT_ACLS                #x00000008)
(*define FILE_FILE_COMPRESSION               #x00000010)
(*define FILE_VOLUME_QUOTAS                  #x00000020)
(*define FILE_SUPPORTS_SPARSE_FILES          #x00000040)
(*define FILE_SUPPORTS_REPARSE_POINTS        #x00000080)
(*define FILE_SUPPORTS_REMOTE_STORAGE        #x00000100)
(*define FILE_VOLUME_IS_COMPRESSED           #x00008000)
(*define FILE_SUPPORTS_OBJECT_IDS            #x00010000)
(*define FILE_SUPPORTS_ENCRYPTION            #x00020000)
(*define FILE_NAMED_STREAMS                  #x00040000)
(*define FILE_READ_ONLY_VOLUME               #x00080000)
(*define FILE_SEQUENTIAL_WRITE_ONCE          #x00100000)
(*define FILE_SUPPORTS_TRANSACTIONS          #x00200000)
