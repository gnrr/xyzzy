;;; -*- Mode: Lisp; Package: FOREIGN -*-
;;;
;;; This file is part of xyzzy.
;;;

(provide "WinSDK/foreign")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign"))

(in-package "foreign")

(export '(include c-if sizeof
	  typedef-c-struct *typedef-c-struct
	  define-c-union *define-c-union
	  ;define-c-struct-union *define-c-struct-union
	  define-c-enum *define-c-enum
	  define-c-function *define-c-function
	  make-c-function-pointer call-c-proc-address
	  define-c-proc-address *define-c-proc-address
	  make-c-type-chunk c-type-chunk-value
	  initialize-c-type-chunk))


(defmacro include (module-name)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (require ,module-name)))

(setf (get 'c-if 'ed:lisp-indent-hook) 1)

(defmacro c-if (&body body)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (if ,@body)))

(defmacro sizeof (type)
  (ctypedef-size (expand-c-type type)))

(defun typedef-c-struct-expand (struct name export)
  (check-type name symbol)
  (let ((type (expand-c-type struct)))
    (unless (ctypedef-slots type)
      (error "~Aは構造体ではありません" type))
    (let* ((sname (string name))
	   (constructor (intern (concatenate 'string "make-" sname)))
	   (predicate (intern (concatenate 'string sname "-p"))))
      `(eval-when (:compile-toplevel :load-toplevel :execute)
	 (when ,export
	   (export ',name)
	   (export ',constructor)
	   (export ',predicate))
	 ;; declare type
	 (setf (get ',name 'c-type-specifier) (copy-c-type-definition ,type))

	 ;; constructor and accessor
	 (defun ,constructor (&optional #2=#:chunk #3=#:offset)
	   (si:make-chunk ',name (ctypedef-size ,type) #2# #3#))
	 (defsetf ,constructor (#2# &optional #3#) (#4=#:value)
	   `(progn
	      (si:copy-chunk ,#4# ,#2# nil nil ,#3#)
	      ,#4#))
	 ;; predicate
	 (defun ,predicate (#1=#:chunk)
	   (eq (si:chunk-type #1#) ',name))
	 ;; accessors
	 ,@(make-c-struct-accessors (ctypedef-slots type)
				    (concatenate 'string sname "-")
				    0 export)
	 ',name))))

(defmacro typedef-c-struct (struct name)
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (typedef-c-struct-expand struct name *c-typedef-auto-export*)))

(defmacro *typedef-c-struct (struct name)
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (typedef-c-struct-expand struct name t)))

(defun define-c-union-expand-1 (slots &optional (offset 0))
  (mapcar #'(lambda (slot)
	      (let (type dims name size)
		(when (endp slot)
		  (error "不正なスロットの形式です"))
		(setq type (expand-c-type (car slot)))
		(pop slot)
		(when (endp slot)
		  (error "不正なスロットの形式です"))
		(when (eq (car slot) '*)
		  (setq type (expand-c-type ':int32))
		  (pop slot)
		  (when (endp slot)
		    (error "不正なスロットの形式です")))
		(setq size (ctypedef-size type))
		(when (zerop size)
		  (error ":void型は構造体のメンバには使用できません"))
		(setq name (car slot))
		(unless (symbolp name)
		  (error "スロット名はシンボルです: ~A" name))
		(pop slot)
		(unless (endp slot)
		  (setq dims (car slot))
		  (when (symbolp dims)
		    (setq dims (symbol-value dims)))
		  (unless (integerp dims)
		    (error "配列の長さは整数です: ~A" dims))
		  (when (<= dims 0)
		    (error "不正な配列の長さです: ~A" dims))
		  (unless (endp (cdr slot))
		    (error "スロットの引数が多すぎます")))
		(setq size (if dims (* dims size) size))
		(make-c-structure-slot :name name :type type
				       :offset offset :size size)))
	  slots))

(defun define-c-union-expand (name slots export)
  (check-type name symbol)
  (when (endp slots)
    (error "共用体のメンバがありません: ~A" name))
  (let* ((sname (string name))
	 (constructor (intern (concatenate 'string "make-" sname)))
	 (predicate (intern (concatenate 'string sname "-p")))
	 (slotdef (define-c-union-expand-1 slots))
	 (size (do* ((i 0 (+ i 1))
		     (slot (nth i slots) (nth i slots))
		     (size 0))
		   ((not slot)
		    size)
		 (when (< size (ctypedef-size (expand-c-type (car slot))))
		   (setf size (ctypedef-size (expand-c-type (car slot))))))))
    `(eval-when (:compile-toplevel :load-toplevel :execute)
       (when ,export
	 (export ',name)
	 (export ',constructor)
	 (export ',predicate))
       ;; declare type
       (setf (get ',name 'c-type-specifier)
	     (make-c-type-definition
	      :type ',name
	      :size ,size
	      :slots (list ,@(mapcar
			      #'(lambda (slot)
				  `(make-c-structure-slot
				    :name ',(cslot-name slot)
				    :type (get ',(ctypedef-type (cslot-type slot))
					       'c-type-specifier)
				    :offset ,(cslot-offset slot)
				    :size ,(cslot-size slot)))
			      slotdef))
	      :accessor ',constructor))

       ;; constructor and accessor
       (defun ,constructor (&optional #2=#:chunk #3=#:offset)
	 (si:make-chunk ',name ,size #2# #3#))
       (defsetf ,constructor (#2# &optional #3#) (#4=#:value)
	 `(progn
	    (si:copy-chunk ,#4# ,#2# nil nil ,#3#)
	    ,#4#))
       ;; predicate
       (defun ,predicate (#1=#:chunk)
	 (eq (si:chunk-type #1#) ',name))
       ;; accessors
       ,@(make-c-struct-accessors slotdef
				  (concatenate 'string sname "-")
				  0 export)
       ',name)))

(setf (get 'define-c-union 'ed:lisp-indent-hook) 'defun)
(setf (get '*define-c-union 'ed:lisp-indent-hook) 'defun)

(defmacro define-c-union (name &rest slots)
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (define-c-union-expand name slots *c-typedef-auto-export*)))

(defmacro *define-c-union (name &rest slots)
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (define-c-union-expand name slots t)))

#|
(defun define-c-struct-union-expand (name slots export)
  (check-type name symbol)
  (let ((union-slots (cdr (find :union slots :key 'car)))
	max-union-slot c-struct-expand)
    (unless union-slots
      (error "共用体のメンバがありません: ~A" name))
    (setf max-union-slot (nth (do* ((i 0 (+ i 1))
				    (slot (nth i union-slots) (nth i union-slots))
				    (c '(0 . 0)))
				  ((not slot)
				   (car c))
				(when (< (cdr c) (ctypedef-size (expand-c-type (car slot))))
				  (setf c (cons i (ctypedef-size (expand-c-type (car slot)))))))
			      union-slots)
	  (nth (position :union slots :key 'car) slots) max-union-slot
	  c-struct-expand `(,(if export '*define-c-struct 'define-c-struct)
			    ,name
			    ,@slots))
    (when (= (list-length union-slots) 1)
      (return-from define-c-struct-union-expand c-struct-expand))
    `(eval-when (:compile-toplevel :load-toplevel :execute)
       ,c-struct-expand
       (let* ((struct-slots (ctypedef-slots (expand-c-type ',name)))
	      (union-slots (define-c-union-expand-1 ',union-slots (c-struct-offset-of ,name ,(second max-union-slot))))
	      (pos (position ',(second max-union-slot) struct-slots
			     :key #'(lambda (slot)
				      (cslot-name slot))))
	      temp-slots)
	 (when (plusp pos)
	   (setf temp-slots struct-slots
		 struct-slots (nthcdr (+ pos 1) struct-slots))
	   (rplacd (nthcdr (- pos 1) temp-slots) nil))
	 (setf (ctypedef-slots (expand-c-type ',name)) (append temp-slots union-slots struct-slots))
	 (dolist (func (make-c-struct-accessors union-slots
						(concatenate 'string ,(string name) "-")
						0 ,export))
	   (eval func))
	 ',name))))

(setf (get 'define-c-struct-union 'ed:lisp-indent-hook) 'defun)
(setf (get '*define-c-struct-union 'ed:lisp-indent-hook) 'defun)

(defmacro define-c-struct-union (name &rest slots)
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (define-c-struct-union-expand name slots *c-typedef-auto-export*)))

(defmacro *define-c-struct-union (name &rest slots)
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (define-c-struct-union-expand name slots t)))
|#

(defun define-c-enum-expand (name slots export)
  (check-type name symbol)
  (when (endp slots)
    (error "列挙子がありません: ~A" name))
  (let ((num 0)
	slotdef)
    (dolist (slot slots)
      (let (name value)
	(when (endp slot)
	  (error "不正なスロットの形式です"))
	(setf name (pop slot))
	(unless (symbolp name)
	  (error "スロット名はシンボルです: ~A" name))
	(if (endp slot)
	    (setf value num)
	    (progn
	      (setf value (pop slot))
	      (when (symbolp value)
		(setf value (or (third (find value slotdef :key 'second))
				(symbol-value value))))
	      (unless (integerp value)
		(error "列挙子の値は整数です: ~A" value))
	      (unless (endp slot)
		(error "スロットの引数が多すぎます"))))
	(unless (< (integer-length value) (* (sizeof int) 8))
	  (error "定数が大きすぎます: ~A" value))
	(setf num (+ value 1))
	(push (list (if export '*define 'define) name value) slotdef)))
    (push (list (if export '*define-c-type 'define-c-type) 'int name) slotdef)
    `(eval-when (:compile-toplevel :load-toplevel :execute)
       ,@slotdef
       ',name)))

(setf (get 'define-c-enum 'ed:lisp-indent-hook) 'defun)
(setf (get '*define-c-enum 'ed:lisp-indent-hook) 'defun)

(defmacro define-c-enum (name &rest slots)
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (define-c-enum-expand name slots *c-typedef-auto-export*)))

(defmacro *define-c-enum (name &rest slots)
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (define-c-enum-expand name slots t)))

(setf (get 'define-c-function 'ed:lisp-indent-hook) 'defun)
(setf (get '*define-c-function 'ed:lisp-indent-hook) 'defun)

(defmacro define-c-function (name sym)
  `(setf (symbol-function ',name) #',sym))

(defmacro *define-c-function (name sym)
  `(progn
     (define-c-function ,name ,sym)
     (export ',name)))

;; 関数ポインタ操作用関数
(define-c-type (void *) lisp)

(define-c-struct
 ldll_function
 (lisp module)          ; DLLモジュールオブジェクト
 (lisp name)            ; DLL内の名前
 ((int *) proc)         ; 関数のポインタ
 ((u_char *) arg_types) ; 引数の型
 (u_short arg_size)     ; 引数全体のサイズ
 (u_char nargs)         ; 引数の数
 (u_char return_type))  ; 戻り値の型

(defun make-c-function-pointer (proc-address args result-type)
  (let ((pf (si:make-c-function (si:load-dll-module "kernel32") "BaseThreadInitThunk" args result-type)))
    (setf (ldll_function-proc (make-ldll_function nil (si:address-of pf))) proc-address)
    pf))

(defmacro call-c-proc-address (return-type (&rest arg-type) proc-address (&rest args))
  `(funcall (make-c-function-pointer ,proc-address
				     ',(mapcar #'c-argument-type arg-type)
				     ',(c-return-type return-type))
	    ,@args))

(setf (get 'define-c-proc-address 'ed:lisp-indent-hook) 'defun)
(setf (get '*define-c-proc-address 'ed:lisp-indent-hook) 'defun)

(defmacro define-c-proc-address (return-type name (&rest args) proc-address)
  `(defun ,name (&rest args)
     (setf (symbol-function ',name)
	   (make-c-function-pointer ,proc-address
				    ',(mapcar #'c-argument-type args)
				    ',(c-return-type return-type)))
     (apply #',name args)))

(defmacro *define-c-proc-address (return-type name (&rest args) proc-address)
  `(progn
     (define-c-proc-address ,return-type ,name ,args ,proc-address)
     (export ',name)))

;; チャンク操作用関数
(defmacro make-c-type-chunk (c-type &optional (length 1) source offset)
  "c-type用のチャンクを作成"
  (let ((size (ctypedef-size (expand-c-type c-type))))
    (setf size (if (typep length 'integer)
		   (* size length)
		   (list '* size length)))
    `(si:make-chunk ',c-type ,size ,source ,offset)))

(defun c-type-chunk-value (chunk &optional (index 0))
  "c-typeチャンクの値を取得"
  (let ((c-type (expand-c-type (si:chunk-type chunk))))
    (funcall (ctypedef-accessor c-type) chunk (* (ctypedef-size c-type) index))))
(defsetf c-type-chunk-value (chunk &optional (index 0)) (x)
  `(let ((c-type (expand-c-type (si:chunk-type ,chunk))))
     (funcall (get (ctypedef-accessor c-type) 'lisp::setf-update) ,chunk (* (ctypedef-size c-type) ,index) ,x)))

(defun initialize-c-struct-chunk (chunk initial-contents)
  (let ((slots (ctypedef-slots (expand-c-type (si:chunk-type chunk))))
	slot slot-size slot-type accessor func offset)
    (while (and slots initial-contents)
      (setf slot (car slots)
	    slot-size (cslot-size slot)
	    slot-type (cslot-type slot)
	    accessor (ctypedef-accessor slot-type)
	    func (get accessor 'lisp::setf-update)
	    offset (cslot-offset slot))
      (if (= slot-size (ctypedef-size slot-type))
	  (if func
	      (funcall func chunk offset (pop initial-contents))
	      (if (listp (car initial-contents))
		  (initialize-c-struct-chunk (funcall accessor chunk offset) (pop initial-contents))
		  (setf initial-contents (initialize-c-struct-chunk (funcall accessor chunk offset) initial-contents))))
	  (setf initial-contents (initialize-c-type-chunk-vector
				  (si:make-chunk (ctypedef-type slot-type) slot-size chunk offset) initial-contents)))
      (setf slots (cdr slots)))
    (si:clear-chunk chunk (+ offset slot-size))
    initial-contents))

(defun initialize-c-type-chunk-vector (chunk initial-contents)
  (let* ((c-type (si:chunk-type chunk))
	 (type (expand-c-type c-type))
	 (size (ctypedef-size type)))
    (if (ctypedef-slots type)
	(do ((offset 0 (+ offset size)))
	    ((not initial-contents)
	     (si:clear-chunk chunk offset))
	  (if (listp (car initial-contents))
	      (initialize-c-struct-chunk (si:make-chunk c-type size chunk offset) (pop initial-contents))
	      (setf initial-contents (initialize-c-struct-chunk (si:make-chunk c-type size chunk offset) initial-contents))))
	(let ((func (get (ctypedef-accessor type) 'lisp::setf-update))
	      (offset 0))
	  (dolist (contents initial-contents)
	    (funcall func chunk offset contents)
	    (incf offset size))
	  (si:clear-chunk chunk offset)))
    initial-contents))

(defun initialize-c-type-chunk (chunk initial-contents)
  "c-typeチャンクの初期化"
  (initialize-c-type-chunk-vector chunk initial-contents)
  chunk)
