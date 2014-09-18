;;;; CommCtrl.h

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/windows"))

(in-package "winapi")

(provide "WinSDK/api/CommCtrl")

(include "WinSDK/api/PrSht")

;;====== Ranges for control message IDs =======================================
(*define LVM_FIRST               #x1000)      ; ListView messages
(*define TV_FIRST                #x1100)      ; TreeView messages
(*define HDM_FIRST               #x1200)      ; Header messages
(*define TCM_FIRST               #x1300)      ; Tab control messages

(*define CCM_FIRST               #x2000)      ; Common control shared messages
(*define CCM_LAST                (+ CCM_FIRST #x200))

(*define CCM_SETBKCOLOR          (+ CCM_FIRST 1)) ; lParam is bkColor

(*define CCM_SETCOLORSCHEME      (+ CCM_FIRST 2)) ; lParam is color scheme
(*define CCM_GETCOLORSCHEME      (+ CCM_FIRST 3)) ; fills in COLORSCHEME pointed to by lParam
(*define CCM_GETDROPTARGET       (+ CCM_FIRST 4))
(*define CCM_SETUNICODEFORMAT    (+ CCM_FIRST 5))
(*define CCM_GETUNICODEFORMAT    (+ CCM_FIRST 6))

;;====== Generic WM_NOTIFY notification codes =================================
#.(*define-c-macro NM_FIRST (x) `(DWORD ,x))
(*define NM_OUTOFMEMORY          (NM_FIRST -1))
(*define NM_CLICK                (NM_FIRST -2))    ; uses NMCLICK struct
(*define NM_DBLCLK               (NM_FIRST -3))
(*define NM_RETURN               (NM_FIRST -4))
(*define NM_RCLICK               (NM_FIRST -5))    ; uses NMCLICK struct
(*define NM_RDBLCLK              (NM_FIRST -6))
(*define NM_SETFOCUS             (NM_FIRST -7))
(*define NM_KILLFOCUS            (NM_FIRST -8))
;#if (_WIN32_IE >= 0x0300)
(*define NM_CUSTOMDRAW           (NM_FIRST -12))
(*define NM_HOVER                (NM_FIRST -13))
;#endif
;#if (_WIN32_IE >= 0x0400)
(*define NM_NCHITTEST            (NM_FIRST -14))   ; uses NMMOUSE struct
(*define NM_KEYDOWN              (NM_FIRST -15))   ; uses NMKEY struct
(*define NM_RELEASEDCAPTURE      (NM_FIRST -16))
(*define NM_SETCURSOR            (NM_FIRST -17))   ; uses NMMOUSE struct
(*define NM_CHAR                 (NM_FIRST -18))   ; uses NMCHAR struct
;#endif
;#if (_WIN32_IE >= 0x0401)
(*define NM_TOOLTIPSCREATED      (NM_FIRST -19))   ; notify of when the tooltips window is create
;#endif
;#if (_WIN32_IE >= 0x0500)
(*define NM_LDOWN                (NM_FIRST -20))
(*define NM_RDOWN                (NM_FIRST -21))
(*define NM_THEMECHANGED         (NM_FIRST -22))
;#endif

(c-if (>= (ed:os-major-version) 6)
      (progn
	(*define NM_FONTCHANGED          (NM_FIRST -23))
	(*define NM_CUSTOMTEXT           (NM_FIRST -24))    ; uses NMCUSTOMTEXT struct
	(*define NM_TVSTATEIMAGECHANGING (NM_FIRST -24))))  ; uses NMTVSTATEIMAGECHANGING struct, defined after HTREEITEM

;;====== WM_NOTIFY codes (NMHDR.code values) ==================================
(*define NM_FIRST            (DWORD  0))       ; generic to all controls
(*define NM_LAST             (DWORD -99))

(*define TVN_FIRST           (logand #xffffffff -400))       ; treeview
(*define TVN_LAST            (logand #xffffffff -499))

(*define-c-type HANDLE HIMAGELIST)

(*define-dll-entry
 HIMAGELIST ImageList_Create (int int UINT int int) "comctl32")
(*define-dll-entry
 BOOL ImageList_Destroy (HIMAGELIST) "comctl32")

(*define-dll-entry
 BOOL ImageList_BeginDrag (HIMAGELIST int int int) "comctl32")
(*define-dll-entry
 void ImageList_EndDrag () "comctl32")
(*define-dll-entry
 BOOL ImageList_DragEnter (HWND int int) "comctl32")
(*define-dll-entry
 BOOL ImageList_DragLeave (HWND) "comctl32")
(*define-dll-entry
 BOOL ImageList_DragMove (int int) "comctl32")
(*define-dll-entry
 BOOL ImageList_SetDragCursorImage (HIMAGELIST int int int) "comctl32")

(*define-dll-entry
 BOOL ImageList_DragShowNolock (BOOL) "comctl32")
(*define-dll-entry
 HIMAGELIST ImageList_GetDragImage ((POINT *) (POINT *)) "comctl32")

(*define-c-macro TreeView_SetImageList (hwnd himl iImage)
		 `(SNDMSG ,hwnd TVM_SETIMAGELIST ,iImage ,himl))

(*define-c-macro TreeView_CreateDragImage (hwnd hitem)
		 `(SNDMSG ,hwnd TVM_CREATEDRAGIMAGE 0 ,hitem))

(*define-c-struct
 NMTREEVIEWA
 (NMHDR   hdr)
 (UINT    action)
 (TVITEMA itemOld)
 (TVITEMA itemNew)
 (POINT   ptDrag))
(*define-c-type (NMTREEVIEWA *) LPNMTREEVIEWA)

(*define-c-struct
 NMTREEVIEWW
 (NMHDR   hdr)
 (UINT    action)
 (TVITEMW itemOld)
 (TVITEMW itemNew)
 (POINT   ptDrag))
(*define-c-type (NMTREEVIEWW *) LPNMTREEVIEWW)

(*define TVN_SELCHANGINGA    (- TVN_FIRST 1))
(*define TVN_SELCHANGINGW    (- TVN_FIRST 50))
(*define TVN_SELCHANGEDA     (- TVN_FIRST 2))
(*define TVN_SELCHANGEDW     (- TVN_FIRST 51))

(*define TVN_GETDISPINFOA    (- TVN_FIRST 3))
(*define TVN_GETDISPINFOW    (- TVN_FIRST 52))
(*define TVN_SETDISPINFOA    (- TVN_FIRST 4))
(*define TVN_SETDISPINFOW    (- TVN_FIRST 53))

(*define TVN_ITEMEXPANDINGA  (- TVN_FIRST 5))
(*define TVN_ITEMEXPANDINGW  (- TVN_FIRST 54))
(*define TVN_ITEMEXPANDEDA   (- TVN_FIRST 6))
(*define TVN_ITEMEXPANDEDW   (- TVN_FIRST 55))
(*define TVN_BEGINDRAGA      (- TVN_FIRST 7))
(*define TVN_BEGINDRAGW      (- TVN_FIRST 56))
(*define TVN_BEGINRDRAGA     (- TVN_FIRST 8))
(*define TVN_BEGINRDRAGW     (- TVN_FIRST 57))
(*define TVN_DELETEITEMA     (- TVN_FIRST 9))
(*define TVN_DELETEITEMW     (- TVN_FIRST 58))
(*define TVN_BEGINLABELEDITA (- TVN_FIRST 10))
(*define TVN_BEGINLABELEDITW (- TVN_FIRST 59))
(*define TVN_ENDLABELEDITA   (- TVN_FIRST 11))
(*define TVN_ENDLABELEDITW   (- TVN_FIRST 60))
(*define TVN_KEYDOWN         (- TVN_FIRST 12))

(*define TCIF_TEXT               #x0001)
(*define TCIF_IMAGE              #x0002)
(*define TCIF_RTLREADING         #x0004)
(*define TCIF_PARAM              #x0008)
;#if (_WIN32_IE >= 0x0300)
(*define TCIF_STATE              #x0010)

(*define TCIS_BUTTONPRESSED      #x0001)
;#endif
;#if (_WIN32_IE >= 0x0400)
(*define TCIS_HIGHLIGHTED        #x0002)
;#endif

(*define-c-struct
 TCITEMA
 (UINT mask)
 ;#if (_WIN32_IE >= 0x0300)
 (DWORD dwState)
 (DWORD dwStateMask)
 ;#else
 ;   (UINT lpReserved1)
 ;   (UINT lpReserved2)
 ;#endif
 (LPSTR pszText)
 (int cchTextMax)
 (int iImage)
 (LPARAM lParam))
(*define-c-type (TCITEMA *) LPTCITEMA)

(*define-c-struct
 TCITEMW
 (UINT mask)
 ;#if (_WIN32_IE >= 0x0300)
 (DWORD dwState)
 (DWORD dwStateMask)
 ;#else
 ;   (UINT lpReserved1)
 ;   (UINT lpReserved2)
 ;#endif
 (LPWSTR pszText)
 (int cchTextMax)
 (int iImage)
 (LPARAM lParam))
(*define-c-type (TCITEMW *) LPTCITEMW)

(*define TCM_GETITEMA            (+ TCM_FIRST 5))
(*define TCM_GETITEMW            (+ TCM_FIRST 60))

(*define TCM_SETITEMA            (+ TCM_FIRST 6))
(*define TCM_SETITEMW            (+ TCM_FIRST 61))

(*define TCM_INSERTITEMA         (+ TCM_FIRST 7))
(*define TCM_INSERTITEMW         (+ TCM_FIRST 62))

(*define TCM_DELETEITEM          (+ TCM_FIRST 8))

(*define TCM_DELETEALLITEMS      (+ TCM_FIRST 9))

(*define TCM_GETITEMRECT         (+ TCM_FIRST 10))

(*define TCM_GETCURSEL           (+ TCM_FIRST 11))

(*define TCM_SETCURSEL           (+ TCM_FIRST 12))

(*define TCM_HITTEST             (+ TCM_FIRST 13))

(*define TCM_SETITEMEXTRA        (+ TCM_FIRST 14))

(*define TCM_ADJUSTRECT          (+ TCM_FIRST 40))

(*define TCM_SETITEMSIZE         (+ TCM_FIRST 41))

(*define TCM_REMOVEIMAGE         (+ TCM_FIRST 42))

(*define TCM_SETPADDING          (+ TCM_FIRST 43))

(*define TCM_GETROWCOUNT         (+ TCM_FIRST 44))

(*define TCM_GETTOOLTIPS         (+ TCM_FIRST 45))

(*define TCM_SETTOOLTIPS         (+ TCM_FIRST 46))

(*define TCM_GETCURFOCUS         (+ TCM_FIRST 47))

(*define TCM_SETCURFOCUS         (+ TCM_FIRST 48))

;#if (_WIN32_IE >= 0x0300)
(*define TCM_SETMINTABWIDTH      (+ TCM_FIRST 49))

(*define TCM_DESELECTALL         (+ TCM_FIRST 50))
;#endif

;#if (_WIN32_IE >= 0x0400)
(*define TCM_HIGHLIGHTITEM       (+ TCM_FIRST 51))

(*define TCM_SETEXTENDEDSTYLE    (+ TCM_FIRST 52))

(*define TCM_GETEXTENDEDSTYLE    (+ TCM_FIRST 53))

(*define TCM_SETUNICODEFORMAT    CCM_SETUNICODEFORMAT)

(*define TCM_GETUNICODEFORMAT    CCM_GETUNICODEFORMAT)
;#endif      // _WIN32_IE >= 0x0400
