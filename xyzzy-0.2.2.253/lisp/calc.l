;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is part of xyzzy.
;;;

(provide "calc")

(in-package "editor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(calc *calc-mode-hook* calc-mode *calc-mode-map* calc-eval-line)))

(defvar *calc-mode-hook* nil)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *calc-package* (defpackage "calc"
			   (:use)
			   (:internal-size 30)
			   (:external-size 0)))
  (unuse-package "lisp" *calc-package*))

(defconstant *calc-token-alist*
  '((#\+ . +) (#\- . -) (#\* . *) (#\/ . /) (#\% . rem) (#\= . =) (#\\ . truncate)
    (#\, . comma) (#\^ . expt) (#\! . !) (#\~ . lognot)
    (#\< (#\< . calc-lshift)) (#\> (#\> . calc-rshift))
    (#\& . logand) (#\| . logior) (#\` . logxor) (#\( . lparen) (#\) . rparen)))

(labels ((set-token-name (c s l)
	   (cond ((listp l)
		  (dolist (x l)
		    (set-token-name (car x) (cons c s) (cdr x))))
		 (s
		  (setf (get l 'calc-operator)
			(format nil "~{~A~}~A" (reverse s) (if c c ""))))
		 (t
		  (setf (get l 'calc-operator) c)))))
  (dolist (x *calc-token-alist*)
    (set-token-name (car x) nil (cdr x))))

(defvar *calc-bits* nil)
(defvar *calc-radix* 10)
(defvar *calc-unsigned* nil)
(defvar *calc-ratio* 'ratio)

(defvar *calc-token* nil)

(defconstant calc::pi pi)
(defconstant calc::e (exp 1.0d0))

(defconstant calc::人生、宇宙、すべての答え 42)
(defconstant calc::生命、宇宙、そのすべてに対する答え
  calc::人生、宇宙、すべての答え)
(defconstant calc::生命、宇宙、そして万物についての答え
  calc::人生、宇宙、すべての答え)
(defconstant calc::生命、宇宙、そして万物についての究極の疑問の答え
  calc::人生、宇宙、すべての答え)

(setf (symbol-function 'calc::gcd) #'gcd)
(setf (symbol-function 'calc::lcm) #'lcm)
(setf (symbol-function 'calc::exp) #'exp)
(setf (symbol-function 'calc::expt) #'expt)
(setf (symbol-function 'calc::pow) #'expt)
(setf (symbol-function 'calc::log) #'log)
(setf (symbol-function 'calc::log10) #'(lambda (x) (log (float x 0d0) 10d0)))
(setf (symbol-function 'calc::sqrt) #'sqrt)
(setf (symbol-function 'calc::isqrt) #'isqrt)
(setf (symbol-function 'calc::abs) #'abs)
(setf (symbol-function 'calc::sin) #'sin)
(setf (symbol-function 'calc::cos) #'cos)
(setf (symbol-function 'calc::tan) #'tan)
(setf (symbol-function 'calc::asin) #'asin)
(setf (symbol-function 'calc::acos) #'acos)
(setf (symbol-function 'calc::atan) #'atan)
(setf (symbol-function 'calc::atan2) #'(lambda (y x) (atan y x)))
(setf (symbol-function 'calc::sinh) #'sinh)
(setf (symbol-function 'calc::cosh) #'cosh)
(setf (symbol-function 'calc::tanh) #'tanh)
(setf (symbol-function 'calc::asinh) #'asinh)
(setf (symbol-function 'calc::acosh) #'acosh)
(setf (symbol-function 'calc::atanh) #'atanh)
(setf (symbol-function 'calc::floor) #'floor)
(setf (symbol-function 'calc::ceil) #'ceiling)
(setf (symbol-function 'calc::ceiling) #'ceiling)
(setf (symbol-function 'calc::trunc) #'truncate)
(setf (symbol-function 'calc::truncate) #'truncate)
(setf (symbol-function 'calc::round) #'round)
(setf (symbol-function 'calc::rem) #'rem)
(setf (symbol-function 'calc::mod) #'mod)
(setf (symbol-function 'calc::ffloor) #'ffloor)
(setf (symbol-function 'calc::fceiling) #'fceiling)
(setf (symbol-function 'calc::fceil) #'fceiling)
(setf (symbol-function 'calc::ftruncate) #'ftruncate)
(setf (symbol-function 'calc::ftrunc) #'ftruncate)
(setf (symbol-function 'calc::fround) #'fround)
(setf (symbol-function 'calc::float) #'(lambda (x) (float x 0d0)))
(setf (symbol-function 'calc::int) #'truncate)
(setf (symbol-function 'calc::ratio) #'rationalize)
(setf (symbol-function 'calc::complex) #'complex)
(setf (symbol-function 'calc::phase) #'phase)
(setf (symbol-function 'calc::cis) #'cis)
(setf (symbol-function 'calc::min) #'min)
(setf (symbol-function 'calc::max) #'max)
(setf (symbol-function 'calc::conjugate) #'conjugate)
(setf (symbol-function 'calc::signum) #'signum)
(setf (symbol-function 'calc::sign) #'signum)
(setf (symbol-function 'calc::realpart) #'realpart)
(setf (symbol-function 'calc::real) #'realpart)
(setf (symbol-function 'calc::imagpart) #'imagpart)
(setf (symbol-function 'calc::imag) #'imagpart)
(setf (symbol-function 'calc::numerator) #'numerator)
(setf (symbol-function 'calc::num) #'numerator)
(setf (symbol-function 'calc::denominator) #'denominator)
(setf (symbol-function 'calc::den) #'denominator)
(setf (symbol-function 'calc::ash) #'ash)
(setf (symbol-function 'calc::shift) #'ash)
(setf (symbol-function 'calc::random) #'random)
(setf (symbol-function 'calc::rand) #'random)

(defun calc::fibonacci (n)
  (check-type n integer)
  (cond ((not (plusp n))
	 (error 'range-error :datum n))
	((= n 1) 1)
	((= n 2) 1)
	(t
	 (do* ((f1 1 f2)
	       (f2 1 f)
	       (f (+ f1 f2) (+ f1 f2))
	       (x 3 (+ x 1)))
	     ((>= x n) f)))))

(setf (symbol-function 'calc::fib) #'calc::fibonacci)

(defun calc-fact (n)
  (check-type n integer)
  (when (minusp n)
    (error 'range-error :datum n))
  (do* ((i 1 (+ i 1))
	(r 1 (* i r)))
      ((>= i n) r)))

(setf (symbol-function 'calc::fact) #'calc-fact)

(defmacro calc::sigma (var from to sexp)
  `(do ((,var ,from (1+ ,var))
	(#1=#:sum 0))
       ((> ,var ,to) #1#)
     (setq #1# (+ #1# ,sexp))))

(setf (symbol-function 'calc-lshift) #'ash)
(defun calc-rshift (x y) (ash x (- y)))

(defun calc-token-string (x)
  (or (and (symbolp x) (get x 'calc-operator)) x ""))

(defun calc-get-token (c s fn)
  (with-output-to-string (so)
    (when c
      (write-char c so))
    (loop
      (setq c (read-char s nil nil))
      (unless c
	(return))
      (unless (funcall fn c)
	(unread-char c s)
	(return))
      (write-char c so))))

(defun calc-next-token (s)
  (loop
    (let ((c (read-char s nil nil)))
      (cond ((null c)
	     (return nil))
	    ((let ((tok (assoc c *calc-token-alist*)))
	       (when tok
		 (return (loop
			   (let ((al (cdr tok)))
			     (unless (listp al)
			       (return al))
			     (setq c (read-char s nil nil))
			     (setq tok (assoc c al))
			     (unless tok
			       (setq tok (assoc nil al))
			       (cond ((null tok)
				      (if c
					  (error "Syntax error: ~c" c)
					(error "Unexpected EOL")))
				     (c
				      (unread-char c s))))))))))
	    ((or (digit-char-p c)
		 (char= c #\.))
	     (when (char= c #\0)
	       (let ((c (read-char s nil nil)))
		 (unless c
		   (return 0))
		 (let ((base (cond ((char-equal c #\x) 16)
				   ((char-equal c #\b) 2)
				   ((digit-char-p c 8)
				    (unread-char c s)
				    8)
				   (t
				    (unread-char c s)
				    nil))))
		   (when base
		     (return (parse-integer
			      (calc-get-token nil s
					      #'(lambda (c)
						  (digit-char-p c base)))
			      :radix base))))))
	     (let ((state 'leadnum)
		   (invalid-p nil))
	       (flet ((flonum (c)
			(setq state
			      (cond ((digit-char-p c)
				     (case state
				       ((leadnum trailnum expnum) state)
				       (dot 'trailnum)
				       ((expchar expsign) 'expnum)))
				    ((char= c #\.)
				     (case state
				       (leadnum 'dot)
				       (t (setq invalid-p state))))
				    ((char-equal c #\e)
				     (case state
				       ((leadnum dot trailnum) 'expchar)
				       ((expchar expsign)
					(setq invalid-p state))
				       (expnum nil)))
				    ((or (char= c #\+)
					 (char= c #\-))
				     (case state
				       ((leadnum dot trailnum expnum) nil)
				       (expchar 'expsign)
				       (t (setq invalid-p state))))
				    (t
				     (case state
				       ((leadnum dot trailnum expnum) nil)
				       (t (setq invalid-p state))))))))
		 (flonum c)
		 (let* ((tok (read-from-string (calc-get-token c s #'flonum))))
		   (when (or invalid-p (not (numberp tok)))
		     (error "Invalid format: ~a" tok))
		   (return tok)))))
	    ((find c " \t\n\r\f"))
	    ((or (alpha-char-p c)
		 (kanji-char-p c)
		 (char= c #\_))
	     (return (intern (calc-get-token c s #'(lambda (c)
						     (or (alphanumericp c)
							 (kanji-char-p c)
							 (char= c #\_))))
			     *calc-package*)))
	    (t
	     (error "Syntax error: ~c" c))))))

(defmacro calc-assoc-left (name next operators)
  `(defun ,name ()
     (let ((left (,next)))
       (while (,(if (listp operators) 'member 'eq) (car *calc-token*) ',operators)
	 (setq left `(,(pop *calc-token*) ,left ,(,next))))
       left)))

(defmacro calc-assoc-right (name next operators)
  `(defun ,name ()
     (let ((left (,next)))
       (if (,(if (listp operators) 'member 'eq) (car *calc-token*) ',operators)
	   `(,(pop *calc-token*) ,left ,(,name))
	 left))))

(defun calc-expr-list ()
  (when (eq (car *calc-token*) 'rparen)
    (pop *calc-token*)
    (return-from calc-expr-list nil))
  (let ((list nil))
    (loop
      (push (calc-expr) list)
      (cond ((eq (car *calc-token*) 'comma)
	     (pop *calc-token*))
	    ((eq (car *calc-token*) 'rparen)
	     (pop *calc-token*)
	     (return (nreverse list)))
	    (t
	     (error ") expected."))))))

(defun calc-primary-expr ()
  (let ((tok (car *calc-token*)))
    (cond ((numberp tok)
	   (pop *calc-token*)
	   tok)
	  ((and (symbolp tok)
		(eq (symbol-package tok) *calc-package*))
	   (pop *calc-token*)
	   (cond ((eq (car *calc-token*) 'lparen)
		  (pop *calc-token*)
		  `(,tok ,@(calc-expr-list)))
		 (t tok)))
	  ((eq (car *calc-token*) 'lparen)
	   (pop *calc-token*)
	   (prog1
	       (calc-expr)
	     (unless (eq (pop *calc-token*) 'rparen)
	       (error ") expected."))))
	  (t (error "Primary expected: ~A" (calc-token-string tok))))))

(defun calc-postfix-expr ()
  (let ((expr (calc-primary-expr)))
    (while (eq (car *calc-token*) '!)
      (pop *calc-token*)
      (setq expr `(calc-fact ,expr)))
    expr))

(defun calc-unary-expr ()
  (if (member (car *calc-token*) '(+ - lognot))
      `(,(pop *calc-token*) ,(calc-unary-expr))
    (calc-postfix-expr)))

(calc-assoc-right calc-power-expr calc-unary-expr expt)

(defun calc-multiplicative-expr ()
  (let ((left (calc-power-expr)))
    (loop
      (let ((ope (car *calc-token*)))
	(cond ((null ope)
	       (return left))
	      ((member ope '(* / rem truncate))
	       (setq left `(,(pop *calc-token*) ,left ,(calc-power-expr))))
	      ((or (and (eq ope 'lparen)
			(not (symbolp left)))
		   (not (and (symbolp ope)
			     (get ope 'calc-operator))))
	       (setq left `(* ,left ,(calc-power-expr))))
	      (t
	       (return left)))))))

(calc-assoc-left calc-additive-expr calc-multiplicative-expr (+ -))
(calc-assoc-left calc-shift-expr calc-additive-expr (calc-lshift calc-rshift))
(calc-assoc-left calc-logand-expr calc-shift-expr logand)
(calc-assoc-left calc-logxor-expr calc-logand-expr logxor)
(calc-assoc-left calc-logior-expr calc-logxor-expr logior)

(defun calc-assign-expr ()
  (let ((left (calc-logior-expr)))
    (cond ((eq (car *calc-token*) '=)
	   (pop *calc-token*)
	   (let ((right (calc-assign-expr)))
	     (cond ((symbolp left)
		    `(setq ,left ,right))
		   ((and (listp left)
			 (symbolp (car left))
			 (eq (symbol-package (car left)) *calc-package*))
		    (dolist (x (cdr left))
		      (or (symbolp x)
			  (error "Syntax error: ~a" (calc-token-string x))))
		    (setf (symbol-function (car left)) `(lambda ,(cdr left) ,right))
		    ''function)
		   (t
		    (error "left operand must be l-value")))))
	  (t left))))

(defun calc-expr ()
  (calc-assign-expr))

(defun calc-options (args)
  (cond (args
	 (while args
	   (let ((var (pop args))
		 (val (when (eq (car args) '=)
			(pop args)
			(pop args))))
	     (cond ((eq var 'calc::bits)
		    (setq *calc-bits*
			  (cond ((member val '(16 32 64)) val)
				((or (null val) (eq val 'calc::unlimit)) nil)
				(t (error "Invalid bits: ~A" (calc-token-string val))))))
		   ((eq var 'calc::radix)
		    (setq *calc-radix*
			  (cond ((member val '(2 8 10 16)) val)
				((eq val 'calc::bin) 2)
				((eq val 'calc::oct) 8)
				((eq val 'calc::dec) 10)
				((eq val 'calc::hex) 16)
				(t (error "Invalid radix: ~A" (calc-token-string val))))))
		   ((eq var 'calc::signed)
		    (setq *calc-unsigned* nil))
		   ((eq var 'calc::unsigned)
		    (setq *calc-unsigned* t))
		   ((eq var 'calc::ratio)
		    (setq *calc-ratio*
			  (cond ((eq val 'calc::int) 'int)
				((eq val 'calc::ratio) 'ratio)
				((eq val 'calc::float) 'float)
				((null val) *calc-ratio*)
				(t (error "Invalid ratio: ~A" (calc-token-string val))))))
		   (t
		    (error "Unknown option: ~A" (calc-token-string var))))))
	 nil)
	(t
	 (format nil "bits=~A radix=~A ~A ratio=~A"
		 (if *calc-bits* *calc-bits* 'unlimit)
		 *calc-radix* (if *calc-unsigned* 'unsigned 'signed) *calc-ratio*))))

(defun calc-string (string)
  (let ((*read-default-float-format* 'double-float)
	(*calc-token* (let ((token nil))
			(with-input-from-string (s string)
			  (do ((tok (calc-next-token s) (calc-next-token s)))
			      ((null tok) (nreverse token))
			    (push tok token))))))
    (if (eq (car *calc-token*) 'calc::set)
	(calc-options (cdr *calc-token*))
      (let ((expr (and *calc-token* (calc-expr))))
	(when *calc-token*
	  (error "unexpected ~A." (calc-token-string (car *calc-token*))))
	(eval expr)))))

(defun calc-print-number (x)
  (cond ((complexp x)
	 (insert "complex(")
	 (calc-print-number (realpart x))
	 (insert ", ")
	 (calc-print-number (imagpart x))
	 (insert ")"))
	((si:*ratiop x)
	 (calc-print-number (numerator x))
	 (insert "/")
	 (calc-print-number (denominator x)))
	((integerp x)
	 (cond ((eql *calc-radix* 2)
		(insert (format nil "0b~b" x)))
	       ((eql *calc-radix* 8)
		(insert (format nil "0~o" x)))
	       ((eql *calc-radix* 16)
		(insert (format nil "0x~x" x)))
	       (t
		(insert (format nil "~d" x)))))
	(t
	 (let ((*read-default-float-format* 'double-float))
	   (insert (format nil "~a" x))))))

(defun calc-eval-line ()
  (interactive)
  (let ((result nil))
    (when (save-excursion
	    (goto-bol)
	    (looking-at "^ *\\$"))
      (handler-case
	  (let ((*read-default-float-format* 'double-float))
	    (setq result (calc-string (buffer-substring (match-end 0)
							(progn
							  (goto-eol)
							  (point))))))
	(error (c)
	  (setq result (let ((*package* *calc-package*)) (si:*condition-string c))))))
    (goto-eol)
    (when result
      (insert "\n")
      (when (si:*ratiop result)
	(cond ((eq *calc-ratio* 'int)
	       (setq result (truncate result)))
	      ((eq *calc-ratio* 'float)
	       (setq result (float result 1d0)))))
      (when (and (integerp result) *calc-bits*)
	(setq result (logand result (- (ash 1 *calc-bits*) 1)))
	(when (and (null *calc-unsigned*)
		   (logbitp (- *calc-bits* 1) result))
	  (setq result (- result (ash 1 *calc-bits*)))))
      (calc-print-number result))
    (insert "\n$ ")))

(defun calc ()
  (interactive)
  (switch-to-buffer "*calc*")
  (calc-mode))

(defun calc-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'calc-mode)
  (setq mode-name "Calc")
  (use-keymap *calc-mode-map*)
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (make-local-variable 'auto-save)
  (setq auto-save nil)
  (goto-char (point-max))
  (unless (bolp)
    (insert #\LFD))
  (insert #\LFD)
  (forward-char -1)
  (insert "$ ")
  (run-hooks '*calc-mode-hook*))

(defvar *calc-mode-map* nil)
(unless *calc-mode-map*
  (setq *calc-mode-map* (make-sparse-keymap))
  (define-key *calc-mode-map* #\RET 'calc-eval-line))

