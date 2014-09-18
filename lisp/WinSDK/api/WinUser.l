;;;; WinUser.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/WinUser")

(*define-c-macro IS_INTRESOURCE (_r)
		 `(= (ash ,_r -16) 0))
(*define-c-macro MAKEINTRESOURCE (i)
		 `(WORD ,i))

(*define-c-macro MAKEWPARAM (l h)  `(MAKELONG ,l ,h))
(*define-c-macro MAKELPARAM (l h)  `(MAKELONG ,l ,h))
(*define-c-macro MAKELRESULT (l h) `(MAKELONG ,l ,h))

#|
| WM_SIZE message wParam values
|#
(*define SIZE_RESTORED           0)
(*define SIZE_MINIMIZED          1)
(*define SIZE_MAXIMIZED          2)
(*define SIZE_MAXSHOW            3)
(*define SIZE_MAXHIDE            4)

#|
| Key State Masks for Mouse Messages
|#
(*define MK_LBUTTON          #x0001)
(*define MK_RBUTTON          #x0002)
(*define MK_SHIFT            #x0004)
(*define MK_CONTROL          #x0008)
(*define MK_MBUTTON          #x0010)
(c-if (>= (ed:os-major-version) 5) #| _WIN32_WINNT >= 0x0500 |#
      (progn
	(*define MK_XBUTTON1     #x0020)
	(*define MK_XBUTTON2     #x0040)))

#|
|  Predefined Clipboard Formats
|#
(*define CF_TEXT            1)
(*define CF_BITMAP          2)
(*define CF_METAFILEPICT    3)
(*define CF_SYLK            4)
(*define CF_DIF             5)
(*define CF_TIFF            6)
(*define CF_OEMTEXT         7)
(*define CF_DIB             8)
(*define CF_PALETTE         9)
(*define CF_PENDATA         10)
(*define CF_RIFF            11)
(*define CF_WAVE            12)
(*define CF_UNICODETEXT     13)
(*define CF_ENHMETAFILE     14)
(c-if (>= (ed:os-major-version) 4) #| WINVER >= 0x0400 |#
      (progn
	(*define CF_HDROP       15)
	(*define CF_LOCALE      16)))
(c-if (>= (ed:os-major-version) 5) #| WINVER >= 0x0500 |#
      (*define CF_DIBV5         17))

(c-if (>= (ed:os-major-version) 5)
      (*define CF_MAX           18)
      (c-if (>= (ed:os-major-version) 4)
	    (*define CF_MAX         17)
	    (*define CF_MAX         15)))

(*define CF_OWNERDISPLAY    #x0080)
(*define CF_DSPTEXT         #x0081)
(*define CF_DSPBITMAP       #x0082)
(*define CF_DSPMETAFILEPICT #x0083)
(*define CF_DSPENHMETAFILE  #x008E)

#|
| "Private" formats don't get GlobalFree()'d
|#
(*define CF_PRIVATEFIRST    #x0200)
(*define CF_PRIVATELAST     #x02FF)

#|
| "GDIOBJ" formats do get DeleteObject()'d
|#
(*define CF_GDIOBJFIRST     #x0300)
(*define CF_GDIOBJLAST      #x03FF)

(*define-c-struct
 NMHDR
 (HWND     hwndFrom)
 (UINT_PTR idFrom)
 (UINT     code))         ; NM_ code
(*define-c-type (NMHDR *) LPNMHDR)

(*define-dll-entry
 BOOL PostMessage (HWND UINT WPARAM LPARAM) "user32" "PostMessageA")

(*define-dll-entry
 LRESULT CallWindowProc (WNDPROC HWND UINT WPARAM LPARAM) "user32" "CallWindowProcA")

#|
| Special value for CreateWindow, et al.
|#
(*define HWND_DESKTOP 0)

(*define-dll-entry
 UINT RegisterClipboardFormatA (LPCSTR) "user32")
(*define-dll-entry
 UINT RegisterClipboardFormatW (LPCWSTR) "user32")

(*define-dll-entry
 SHORT GetAsyncKeyState (int) "user32")

(*define-dll-entry
 HWND GetCapture () "user32")

(*define-dll-entry
 HWND SetCapture (HWND) "user32")

(*define-dll-entry
 BOOL ReleaseCapture () "user32")

(*define-dll-entry
 HMENU GetMenu (HWND) "user32")
(*define-dll-entry
 BOOL SetMenu (HWND HMENU) "user32")

(*define-dll-entry
 BOOL SetPropA (HWND LPCSTR HANDLE) "user32")
(*define-dll-entry
 BOOL SetPropW (HWND LPCWSTR HANDLE) "user32")

(*define-dll-entry
 HANDLE GetPropA (HWND LPCSTR) "user32")
(*define-dll-entry
 HANDLE GetPropW (HWND LPCWSTR) "user32")

(*define-dll-entry
 HANDLE RemovePropA (HWND LPCSTR) "user32")
(*define-dll-entry
 HANDLE RemovePropW (HWND LPCWSTR) "user32")

(*define-dll-entry
 HCURSOR SetCursor (HCURSOR) "user32")

(*define-dll-entry
 BOOL GetCaretPos ((POINT *)) "user32")

(*define-dll-entry
 BOOL ClientToScreen (HWND LPPOINT) "user32")

(*define-dll-entry
 BOOL ScreenToClient (HWND LPPOINT) "user32")

(*define-dll-entry
 int MapWindowPoints (HWND HWND LPPOINT UINT) "user32")

(*define-dll-entry
 BOOL DrawFocusRect (HDC (RECT *)) "user32")

(*define-dll-entry
 HWND GetParent (HWND) "user32")

(*define-dll-entry
 HWND SetParent (HWND HWND) "user32")

(*define-dll-entry
 HWND FindWindowExA (HWND HWND LPCSTR LPCSTR) "user32")
(*define-dll-entry
 HWND FindWindowExW (HWND HWND LPCWSTR LPCWSTR) "user32")

#|
| Standard Cursor IDs
|#
(*define IDC_ARROW       (MAKEINTRESOURCE 32512))
(*define IDC_IBEAM       (MAKEINTRESOURCE 32513))
(*define IDC_WAIT        (MAKEINTRESOURCE 32514))
(*define IDC_CROSS       (MAKEINTRESOURCE 32515))
(*define IDC_UPARROW     (MAKEINTRESOURCE 32516))
(*define IDC_SIZE        (MAKEINTRESOURCE 32640))  #| OBSOLETE: use IDC_SIZEALL |#
(*define IDC_ICON        (MAKEINTRESOURCE 32641))  #| OBSOLETE: use IDC_ARROW |#
(*define IDC_SIZENWSE    (MAKEINTRESOURCE 32642))
(*define IDC_SIZENESW    (MAKEINTRESOURCE 32643))
(*define IDC_SIZEWE      (MAKEINTRESOURCE 32644))
(*define IDC_SIZENS      (MAKEINTRESOURCE 32645))
(*define IDC_SIZEALL     (MAKEINTRESOURCE 32646))
(*define IDC_NO          (MAKEINTRESOURCE 32648))  #|not in win3.1 |#
(c-if (>= (ed:os-major-version) 5) #| WINVER >= 0x0500 |#
      (*define IDC_HAND      (MAKEINTRESOURCE 32649)))
(*define IDC_APPSTARTING (MAKEINTRESOURCE 32650))  #|not in win3.1 |#
(c-if (>= (ed:os-major-version) 4) #| WINVER >= 0x0400 |#
      (*define IDC_HELP      (MAKEINTRESOURCE 32651)))

(c-if (>= (ed:os-major-version) 4) #| WINVER >= 0x0400 |#
      (progn
	(*define SIF_RANGE           #x0001)
	(*define SIF_PAGE            #x0002)
	(*define SIF_POS             #x0004)
	(*define SIF_DISABLENOSCROLL #x0008)
	(*define SIF_TRACKPOS        #x0010)
	(*define SIF_ALL             (logior SIF_RANGE SIF_PAGE SIF_POS SIF_TRACKPOS))

	(*define-c-struct
	 SCROLLINFO
	 (UINT cbSize)
	 (UINT fMask)
	 (int  nMin)
	 (int  nMax)
	 (UINT nPage)
	 (int  nPos)
	 (int  nTrackPos))
	(*define-c-type (SCROLLINFO *) LPSCROLLINFO)
	(*define-c-type (SCROLLINFO *) LPCSCROLLINFO)

	(*define-dll-entry
	 int SetScrollInfo (HWND int LPCSCROLLINFO BOOL) "user32")
	(*define-dll-entry
	 BOOL GetScrollInfo (HWND int LPSCROLLINFO) "user32")))
