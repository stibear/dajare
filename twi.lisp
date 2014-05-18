(setf cltter::*key* "")
(setf cltter::*secret* "")
(setf cltter::*access-token-place* #P"./.twi.out")
(setf cltter::*consumer-token*
      (oauth:make-consumer-token :key cltter::*key*
				 :secret cltter::*secret*))

(cltter:twitter-authorize)

(defvar *tweet-hashtag* " #npca #灘校文化祭")

(defun dajare-tweet (string)
  (let ((str-len (length string)))
    (let ((tweet (if (<= (+ str-len (length *tweet-hashtag*)) 140)
		     (concatenate 'string string *tweet-hashtag*)
		     (concatenate 'string
				  (subseq string 0
					  (- 140 (length *tweet-hashtag*)))
				  *tweet-hashtag*))))
      (cltter:tweet tweet))))
