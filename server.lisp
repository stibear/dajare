(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload :ningle)
  (ql:quickload :cl-who)
  (ql:quickload :cl-emb)
  (ql:quickload :trivial-shell))

(defvar *server* (make-instance 'ningle:<app>))
(setf (who:html-mode) :html5)
(setf emb:*escape-type* :html)

(setf (ningle:route *server* "/")
      (who:with-html-output-to-string (str)
	(:html
	 :lang "ja"
	 (:head
	  (:meta :charset "utf-8")
	  (:style :type "text/css"
		  "#exp label { display: block; float: left; width: 300px;}"))
	 (:body
	  (:h1 :align "center"
	       "インテリア")
	  (:form :action "result"
		 :method "GET"
		 (:p :align "center"
		     (:input :type "text"
			     :name "sent"
			     :size "50"
			     :style "font-size:150%;"))
		 (:div :id "exp"
		       :style "margin-left:auto;margin-right:auto;width:300px;"
		       (:label (:input :type "radio"
				       :name "exp"
				       :value "となりの客はよく柿食う客だ")
			       "となりの客はよく柿食う客だ")
		       (:br)
		       (:label (:input :type "radio"
				       :name "exp"
				       :value "鬼の目にも涙")
			       "鬼の目にも涙")
		       (:br)
		       (:label (:input :type "radio"
				       :name "exp"
				       :value "のれんに腕押し")
			       "のれんに腕押し")
		       (:br)
		       (:label (:input :type "radio"
				       :name "exp"
				       :value "光陰矢のごとし")
			       "光陰矢のごとし")
		       (:br))
		 (:div :align "center"
		     (:input :type "submit"
			     :value "ダジャレ送信"
			     :style "background-color:#ffffff;")))))))

(defun gen-dajare (str)
  (read-from-string
   (print
    (trivial-shell:shell-command
     (format nil "gosh dajare.scm ~A" str)))
   nil '("")))

(setf (ningle:route *server* "/result")
      #'(lambda (params)
	  (emb:execute-emb
	   #P"result.html"
	   :env (list :dajare
		      (gen-dajare
		       (if (getf params :|exp|)
			   (getf params :|exp|)
			   (getf params :|sent|)))))))

(let ((app (clack:clackup *server*)))
  (loop
    (if (y-or-n-p)
	(return (clack:stop app)))))

