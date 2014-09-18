;;;; ShlObj.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/ShlObj")

(include "WinSDK/api/Ole2")
;#ifndef _PRSHT_H_
(include "WinSDK/api/PrSht")
;#endif
;#ifndef _INC_COMMCTRL
(include "WinSDK/api/CommCtrl")   ; for LPTBBUTTON
;#endif

(include "WinSDK/api/ShTypes")

(*define CSIDL_DESKTOP                   #x0000)         ; <desktop>
(*define CSIDL_INTERNET                  #x0001)         ; Internet Explorer (icon on desktop)
(*define CSIDL_PROGRAMS                  #x0002)         ; Start Menu\Programs
(*define CSIDL_CONTROLS                  #x0003)         ; My Computer\Control Panel
(*define CSIDL_PRINTERS                  #x0004)         ; My Computer\Printers
(*define CSIDL_PERSONAL                  #x0005)         ; My Documents
(*define CSIDL_FAVORITES                 #x0006)         ; <user name>\Favorites
(*define CSIDL_STARTUP                   #x0007)         ; Start Menu\Programs\Startup
(*define CSIDL_RECENT                    #x0008)         ; <user name>\Recent
(*define CSIDL_SENDTO                    #x0009)         ; <user name>\SendTo
(*define CSIDL_BITBUCKET                 #x000a)         ; <desktop>\Recycle Bin
(*define CSIDL_STARTMENU                 #x000b)         ; <user name>\Start Menu
(*define CSIDL_MYDOCUMENTS               CSIDL_PERSONAL) ;  Personal was just a silly name for My Documents
(*define CSIDL_MYMUSIC                   #x000d)         ; "My Music" folder
(*define CSIDL_MYVIDEO                   #x000e)         ; "My Videos" folder
(*define CSIDL_DESKTOPDIRECTORY          #x0010)         ; <user name>\Desktop
(*define CSIDL_DRIVES                    #x0011)         ; My Computer
(*define CSIDL_NETWORK                   #x0012)         ; Network Neighborhood (My Network Places)
(*define CSIDL_NETHOOD                   #x0013)         ; <user name>\nethood
(*define CSIDL_FONTS                     #x0014)         ; windows\fonts
(*define CSIDL_TEMPLATES                 #x0015)
(*define CSIDL_COMMON_STARTMENU          #x0016)         ; All Users\Start Menu
(*define CSIDL_COMMON_PROGRAMS           #x0017)         ; All Users\Start Menu\Programs
(*define CSIDL_COMMON_STARTUP            #x0018)         ; All Users\Startup
(*define CSIDL_COMMON_DESKTOPDIRECTORY   #x0019)         ; All Users\Desktop
(*define CSIDL_APPDATA                   #x001a)         ; <user name>\Application Data
(*define CSIDL_PRINTHOOD                 #x001b)         ; <user name>\PrintHood
(*define CSIDL_LOCAL_APPDATA             #x001c)         ; <user name>\Local Settings\Applicaiton Data (non roaming)
(*define CSIDL_ALTSTARTUP                #x001d)         ; non localized startup
(*define CSIDL_COMMON_ALTSTARTUP         #x001e)         ; non localized common startup
(*define CSIDL_COMMON_FAVORITES          #x001f)
(*define CSIDL_INTERNET_CACHE            #x0020)
(*define CSIDL_COOKIES                   #x0021)
(*define CSIDL_HISTORY                   #x0022)
(*define CSIDL_COMMON_APPDATA            #x0023)         ; All Users\Application Data
(*define CSIDL_WINDOWS                   #x0024)         ; GetWindowsDirectory()
(*define CSIDL_SYSTEM                    #x0025)         ; GetSystemDirectory()
(*define CSIDL_PROGRAM_FILES             #x0026)         ; C:\Program Files
(*define CSIDL_MYPICTURES                #x0027)         ; C:\Program Files\My Pictures
(*define CSIDL_PROFILE                   #x0028)         ; USERPROFILE
(*define CSIDL_SYSTEMX86                 #x0029)         ; x86 system directory on RISC
(*define CSIDL_PROGRAM_FILESX86          #x002a)         ; x86 C:\Program Files on RISC
(*define CSIDL_PROGRAM_FILES_COMMON      #x002b)         ; C:\Program Files\Common
(*define CSIDL_PROGRAM_FILES_COMMONX86   #x002c)         ; x86 Program Files\Common on RISC
(*define CSIDL_COMMON_TEMPLATES          #x002d)         ; All Users\Templates
(*define CSIDL_COMMON_DOCUMENTS          #x002e)         ; All Users\Documents
(*define CSIDL_COMMON_ADMINTOOLS         #x002f)         ; All Users\Start Menu\Programs\Administrative Tools
(*define CSIDL_ADMINTOOLS                #x0030)         ; <user name>\Start Menu\Programs\Administrative Tools
(*define CSIDL_CONNECTIONS               #x0031)         ; Network and Dial-up Connections
(*define CSIDL_COMMON_MUSIC              #x0035)         ; All Users\My Music
(*define CSIDL_COMMON_PICTURES           #x0036)         ; All Users\My Pictures
(*define CSIDL_COMMON_VIDEO              #x0037)         ; All Users\My Video
(*define CSIDL_RESOURCES                 #x0038)         ; Resource Direcotry
(*define CSIDL_RESOURCES_LOCALIZED       #x0039)         ; Localized Resource Direcotry
(*define CSIDL_COMMON_OEM_LINKS          #x003a)         ; Links to All Users OEM specific apps
(*define CSIDL_CDBURN_AREA               #x003b)         ; USERPROFILE\Local Settings\Application Data\Microsoft\CD Burning
; unused                                 #x003c
(*define CSIDL_COMPUTERSNEARME           #x003d)         ; Computers Near Me (computered from Workgroup membership)
(*define CSIDL_FLAG_CREATE               #x8000)         ; combine with CSIDL_ value to force folder creation in SHGetFolderPath()
(*define CSIDL_FLAG_DONT_VERIFY          #x4000)         ; combine with CSIDL_ value to return an unverified folder path
(*define CSIDL_FLAG_DONT_UNEXPAND        #x2000)         ; combine with CSIDL_ value to avoid unexpanding environment variables
(c-if (>= (ed:os-major-version) 5) ; NTDDI_WINXP
      (progn
	(*define CSIDL_FLAG_NO_ALIAS         #x1000)         ; combine with CSIDL_ value to insure non-alias versions of the pidl
	(*define CSIDL_FLAG_PER_USER_INIT    #x0800)))       ; combine with CSIDL_ value to indicate per-user init (eg. upgrade)
(*define CSIDL_FLAG_MASK                 #xFF00)         ; mask for all possible flag values

(*define-dll-entry
 HRESULT SHGetSpecialFolderLocation (HWND int (LPITEMIDLIST *)) "shell32")

(*define-c-struct
 FILEDESCRIPTORA
 (DWORD    dwFlags)
 (CLSID    clsid)
 (SIZEL    sizel)
 (POINTL   pointl)
 (DWORD    dwFileAttributes)
 (FILETIME ftCreationTime)
 (FILETIME ftLastAccessTime)
 (FILETIME ftLastWriteTime)
 (DWORD    nFileSizeHigh)
 (DWORD    nFileSizeLow)
 (CHAR    cFileName MAX_PATH))
(*define-c-type (FILEDESCRIPTORA *) LPFILEDESCRIPTORA)

(*define-c-struct
 FILEDESCRIPTORW
 (DWORD    dwFlags)
 (CLSID    clsid)
 (SIZEL    sizel)
 (POINTL   pointl)
 (DWORD    dwFileAttributes)
 (FILETIME ftCreationTime)
 (FILETIME ftLastAccessTime)
 (FILETIME ftLastWriteTime)
 (DWORD    nFileSizeHigh)
 (DWORD    nFileSizeLow)
 (WCHAR    cFileName MAX_PATH))
(*define-c-type (FILEDESCRIPTORW *) LPFILEDESCRIPTORW)

(*define-c-struct
 FILEGROUPDESCRIPTORA
 (UINT cItems)
 (FILEDESCRIPTORA fgd 1))
(*define-c-type (FILEGROUPDESCRIPTORA *) LPFILEGROUPDESCRIPTORA)

(*define-c-struct
 FILEGROUPDESCRIPTORW
 (UINT cItems)
 (FILEDESCRIPTORW fgd 1))
(*define-c-type (FILEGROUPDESCRIPTORW *) LPFILEGROUPDESCRIPTORW)
