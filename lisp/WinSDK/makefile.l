(provide "WinSDK/makefile")

(defun WinSDK-make ()
  (interactive)
  (long-operation
    (let ((src-dir (do* ((path *load-path* (cdr path))
			 (dir (merge-pathnames "WinSDK" (car path)) (merge-pathnames "WinSDK" (car path))))
		       ((not path))
		     (when (file-directory-p dir)
		       (return dir))))
	  (count 0))
      (when src-dir
	(unless (require "WinSDK/api/Windows")
	  (dolist (type '(winapi:CLSID winapi:ASYNC_STGMEDIUM))
	    (remprop type 'c::c-type-specifier)))
	(dolist (src (directory src-dir :absolute t :recursive t :wild "*.l"))
	  (compile-file src)
	  (incf count))
	(format t "Total ~[No~:;~:*~d~] file~:*~p compiled~%" count)))))
