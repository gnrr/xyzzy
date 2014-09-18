;;;; winapi用のユーティリティ (by TieC)

(provide "WinSDK/utility")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "WinSDK/api/Windows"))

(in-package "win-user")

(export '(make-wstring-chunk make-tstring-chunk
	  unpack-wstring unpack-tstring
	  get-last-error-message
	  get-client-window-handle-list
	  get-window-msg-hooks-symbol-list get-original-proc-alist
	  set-window-msg-hook unset-window-msg-hook
	  *hWnd* *msg* *wParam* *lParam* *res*))


;; ユニコード文字列を扱うための関数
(defun make-wstring-chunk (string)
  "ユニコード文字列のチャンクを作成"
  (si:make-string-chunk
   (ed:concat (ed:convert-encoding-from-internal ed:*encoding-utf16le* string) "\0")))
(defmacro make-tstring-chunk (string)
  (if (featurep :UNICODE)
      `(make-wstring-chunk ,string)
      `(si:make-string-chunk ,string)))

(defun unpack-wstring (chunk offset &optional size)
  "チャンクからユニコード文字列を取得"
  (string-right-trim "\0" (ed:map-ucs-2-to-internal (si:unpack-string chunk offset size nil))))
(defmacro unpack-tstring (chunk offset &optional size)
  (if (featurep :UNICODE)
      `(unpack-wstring ,chunk ,offset ,size)
      `(si:unpack-string ,chunk ,offset ,size)))

;; エラーメッセージの取得
(defun get-last-error-message ()
  (let* ((lpbuf (make-c-type-chunk LPVOID))
	 (len (FormatMessageA (logior FORMAT_MESSAGE_ALLOCATE_BUFFER
				      FORMAT_MESSAGE_FROM_SYSTEM
				      FORMAT_MESSAGE_MAX_WIDTH_MASK)
			      NULL (GetLastError) 0 lpbuf 0 NULL))
	 (address (c-type-chunk-value lpbuf))
	 (lpstr (make-c-type-chunk CHAR len nil address)))
    (prog1 (si:unpack-string lpstr 0 len)
      (LocalFree address))))

;; クライアントウィンドウのハンドルリストを取得
(defun get-client-window-handle-list (&optional minibuf)
  (let ((window (ed:selected-window))
	wh-list)
    (dotimes (i (ed:count-windows minibuf) wh-list)
      (pushnew (ed:get-window-handle window) wh-list)
      (setf window (ed:next-window window minibuf)))))

;; ウィンドウのサブクラス化
(defun get-window-msg-hooks-symbol-list (hWnd)
  "hookのシンボルを取得:(HookProc before-msg-hook after-msg-hook)"
  (when (integerp hWnd)
    (mapcar #'(lambda (s)
		(intern (format nil s hWnd)))
	    '("~D_HookProc" "*~D-before-msg-hook*" "*~D-after-msg-hook*"))))
(let (original-proc-alist)	;((hWnd . Proc))
  (defun make-window-msg-hooks (hWnd)
    (let ((OriginalProc (GetWindowLong hWnd GWL_WNDPROC))
	  (sym-list (get-window-msg-hooks-symbol-list hWnd)))
      (unless (zerop OriginalProc)
	(eval `(progn
		 (defvar ,(second sym-list) nil)
		 (defvar ,(third sym-list) nil)
		 (defun-c-callable LRESULT ,(first sym-list) ((HWND hWnd) (UINT msg) (WPARAM wParam) (LPARAM lParam))
				   (let ((*hWnd* hWnd) (*msg* msg) (*wParam* wParam) (*lParam* lParam) *res*)
				     (declare (special *hWnd* *msg* *wParam* *lParam* *res*))
				     (ed:run-hook-with-args-while-success ',(second sym-list))
				     (if *res* nil
					 (progn
					   (setq *res* (CallWindowProc ,OriginalProc *hWnd* *msg* *wParam* *lParam*))
					   (ed:run-hook-with-args-while-success ',(third sym-list))))
				     *res*))
		 (SetWindowLong ,hWnd GWL_WNDPROC #',(first sym-list))))
	(pushnew (cons hWnd OriginalProc) original-proc-alist :key 'car))))
  (defun remove-window-msg-hooks (hWnd)
    (let ((old-proc (cdr (assoc hWnd original-proc-alist)))
	  (sym-list (get-window-msg-hooks-symbol-list hWnd)))
      (when old-proc
	(SetWindowLong hWnd GWL_WNDPROC old-proc)
	(makunbound (second sym-list))
	(makunbound (third sym-list))
	(fmakunbound (first sym-list))
	(unintern (second sym-list))
	(unintern (third sym-list))
	(unintern (first sym-list))
	(setf original-proc-alist (delete hWnd original-proc-alist :key 'car))
	t)))
  (defun get-original-proc-alist ()
    "ウィンドウハンドルとウィンドウプロシージャの連想リスト"
    original-proc-alist))
(defun set-window-msg-hook (hWnd hook-proc &optional add-before-msg append)
  "メッセージフックを登録"
  (let ((hook (if add-before-msg
		  (second (get-window-msg-hooks-symbol-list hWnd))
		  (third (get-window-msg-hooks-symbol-list hWnd)))))
    (and (not (boundp hook))
	 (not (make-window-msg-hooks hWnd))
	 (return-from set-window-msg-hook 0))
    (ed:add-hook hook hook-proc append)))
(defun unset-window-msg-hook (hWnd hook-proc &optional add-before-msg)
  "メッセージフックを解除"
  (let* ((sym-list (get-window-msg-hooks-symbol-list hWnd))
	 (hook (if add-before-msg
		   (second sym-list)
		   (third sym-list))))
    (if (boundp hook)
	(prog1
	    (ed:delete-hook hook hook-proc)
	  (or (eval (second sym-list))
	      (eval (third sym-list))
	      (remove-window-msg-hooks hWnd)))
	0)))
