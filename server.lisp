(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload :ningle)
  (ql:quickload :cl-emb)
  (ql:quickload :cl-who)
  (ql:quickload :trivial-shell)
  (ql:quickload :cl-json)
  (ql:quickload :alexandria)
  (ql:quickload :cltter))
  
(load #P"./twi.lisp" :external-format :utf-8)

(defvar *app* (make-instance 'ningle:<app>))
(defvar js-dir
  (make-instance 'clack.middleware.static:<clack-middleware-static>
		 :path "/js/"
		 :root #P"/home/stibear/Scheme/dajare/js/"))
(defvar img-dir
  (make-instance 'clack.middleware.static:<clack-middleware-static>
		 :path "/img/"
		 :root #P"/home/stibear/Scheme/dajare/img/"))
(defvar three-js-dir
  (make-instance 'clack.middleware.static:<clack-middleware-static>
		 :path "/three.js/"
		 :root #P"/home/stibear/Scheme/dajare/three.js/"))
(defvar notice-dir
  (make-instance 'clack.middleware.static:<clack-middleware-static>
		 :path "/toastmessage/"
		 :root #P"/home/stibear/Scheme/dajare/toastmessage/"))
(setf emb:*escape-type* :html)

(defun gen-dajare (str)
  (read-from-string
   (trivial-shell:shell-command
    (format nil "gosh dajare.scm ~A" str))
   nil '("")))

(defun n-first (lst n)
  (labels ((rec (lst n m)
	     (if (or (zerop n) (null (cdr lst)))
		 m
		 (rec (cdr lst) (1- n) (cons (car lst) m)))))
    (rec lst n '())))

(defun divisor (x)
  (loop for i from 2 to x do
    (if (= x i) (return (list x))
	(if (zerop (mod x i))
	    (return (append (list i) (divisor (/ x i))))))))

(defun min-divisors (n)
  (loop for i from (floor (sqrt n)) downto 1
	if (zerop (mod n i))
	   return i))

(defun group (source n)
  (if (zerop n) (error "zero length"))
  (labels ((rec (source acc)
	     (let ((rest (nthcdr n source)))
	       (if (consp rest)
		   (rec rest (cons (subseq source 0 n) acc))
		   (nreverse (cons source acc))))))
    (if source (rec source nil) nil)))

(defmacro lref (list &rest subscripts)
  (reduce
   #'(lambda (x y)
       `(nth ,x ,y))
   (reverse subscripts)
   :from-end t :initial-value list))

(defun table-pprint (lst1)
  (loop for i below (list-length lst1)
	do (loop for j below (list-length (nth i lst1))
		 do (format t "\"~A\", ~A, ~A,~%"
			    (lref lst1 i j) j i))))

(setf (ningle:route *app* "/")
      (emb:execute-emb #P"hoge.html"))

(setf (ningle:route *app* "/result")
      (lambda (params)
	(let ((sent (getf params :|sent|))
	      (exp (getf params :|exp|)))
	  (let* ((dajare (gen-dajare (if (string= sent "")
					 exp
					 sent)))
		 (len (list-length dajare)))
	    (setf len (if (> len 200) 200 len))
	    (emb:execute-emb #P"result3.html"
			     :env `(:dajare
				    ,(group
				      (n-first (alexandria:shuffle dajare)
					       200)
				      (floor (sqrt len)))))))))

(setf (ningle:route *app* "/dajare" :method :get)
      #'(lambda (params)
	  (let ((sent (getf params :|sent|))
		(exp (getf params :|exp|)))
	    )))

(setf (ningle:route *app* "/twitter" :method :get)
      #'(lambda (params)
	  (let ((dajare (getf params :|dajare|)))
	    (ignore-errors
	     (unless (or (null dajare)
			 (string= dajare ""))
	       (dajare-tweet dajare)
	       "done")))))

(ignore-errors
 (let ((app (clack:clackup
	     (clack:wrap
	      notice-dir
	      (clack:wrap
	       three-js-dir
	       (clack:wrap
		img-dir
		(clack:wrap
		 js-dir
		 *app*)))))))
   (loop
     (if (y-or-n-p)
	 (return (clack:stop app))))))
