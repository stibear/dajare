#|
TODO:
* share substring type -> done
* consonant change type -> done
* vowel change type
* a few character addition type
* a few character shift type

* +poster+
* how to use
* difficult description (A2 size)
|#

(use srfi-1)
(use srfi-9)
(use srfi-13)
(use srfi-26)
(use srfi-27)
(use srfi-42)
(use gauche.process)
(use gauche.collection)
(use gauche.threads)
(use gauche.generator)
(use gauche.sequence)
(use util.combinations)
(use file.util)
(use rfc.http)
(use rfc.json)

(define %es% "となりの客はよく柿食う客だ")

(define *word-cost* 5000)

(define *mecab-dictionary*
  "/home/stibear/Downloads/mecab_dic/mecab_dic/user.dic")

(define cnsnnt-nongldng
  '(a k s t n h m y r w g z d b p))
(define cnsnnt-gldng
  '(k s t n h m r g z d b p))
(define vwl-nongldng
  '(a i u e o))
(define vwl-gldng
  '(a u o))

(define conv-hash
  (make-hash-table 'string=?))

(define kanji-match
  #/\/([々〇〻\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF\uD840-\uD87F\uDC00-\uDFFF]+)/)

(define-record-type kana-type
  (kana cnsnnt vwl gldng)
  kana?
  (cnsnnt consonant set-cnsnnt!)
  (vwl vowel set-vwl!)
  (gldng gliding? set-gldng!))

(define kana-je
  '(("あ" . (a a #f))
    ("い" . (a i #f))
    ("う" . (a u #f))
    ("え" . (a e #f))
    ("お" . (a o #f))
    ("か" . (k a #f))
    ("き" . (k i #f))
    ("く" . (k u #f))
    ("け" . (k e #f))
    ("こ" . (k o #f))
    ("さ" . (s a #f))
    ("し" . (s i #f))
    ("す" . (s u #f))
    ("せ" . (s e #f))
    ("そ" . (s o #f))
    ("た" . (t a #f))
    ("ち" . (t i #f))
    ("つ" . (t u #f))
    ("て" . (t e #f))
    ("と" . (t o #f))
    ("な" . (n a #f))
    ("に" . (n i #f))
    ("ぬ" . (n u #f))
    ("ね" . (n e #f))
    ("の" . (n o #f))
    ("は" . (h a #f))
    ("ひ" . (h i #f))
    ("ふ" . (h u #f))
    ("へ" . (h e #f))
    ("ほ" . (h o #f))
    ("ま" . (m a #f))
    ("み" . (m i #f))
    ("む" . (m u #f))
    ("め" . (m e #f))
    ("も" . (m o #f))
    ("や" . (y a #f))
    ("い" . (y i #f))
    ("ゆ" . (y u #f))
    ("え" . (y e #f))
    ("よ" . (y o #f))
    ("ら" . (r a #f))
    ("り" . (r i #f))
    ("る" . (r u #f))
    ("れ" . (r e #f))
    ("ろ" . (r o #f))
    ("わ" . (w a #f))
    ("ゐ" . (w i #f))
    ("う" . (w u #f))
    ("ゑ" . (w e #f))
    ("を" . (w o #f))
    ("ん" . (n #f #f))
    ("が" . (g a #f))
    ("ぎ" . (g i #f))
    ("ぐ" . (g u #f))
    ("げ" . (g e #f))
    ("ご" . (g o #f))
    ("ざ" . (z a #f))
    ("じ" . (z i #f))
    ("ず" . (z u #f))
    ("ぜ" . (z e #f))
    ("ぞ" . (z o #f))
    ("だ" . (d a #f))
    ("ぢ" . (d i #f))
    ("づ" . (d u #f))
    ("で" . (d e #f))
    ("ど" . (d o #f))
    ("ば" . (b a #f))
    ("び" . (b i #f))
    ("ぶ" . (b u #f))
    ("べ" . (b e #f))
    ("ぼ" . (b o #f))
    ("ぱ" . (p a #f))
    ("ぴ" . (p i #f))
    ("ぷ" . (p u #f))
    ("ぺ" . (p e #f))
    ("ぽ" . (p o #f))
    ("きゃ" . (k a #t))
    ("きゅ" . (k u #t))
    ("きょ" . (k o #t))
    ("ぎゃ" . (g a #t))
    ("ぎゅ" . (g u #t))
    ("ぎょ" . (g o #t))
    ("しゃ" . (s a #t))
    ("しゅ" . (s u #t))
    ("しょ" . (s o #t))
    ("ちゃ" . (t a #t))
    ("ちゅ" . (t u #t))
    ("ちょ" . (t o #t))
    ("にゃ" . (n a #t))
    ("にゅ" . (n u #t))
    ("にょ" . (n o #t))
    ("ひゃ" . (h a #t))
    ("ひゅ" . (h u #t))
    ("ひょ" . (h o #t))
    ("みゃ" . (m a #t))
    ("みゅ" . (m u #t))
    ("みょ" . (m o #t))
    ("りゃ" . (r a #t))
    ("りゅ" . (r u #t))
    ("りょ" . (r o #t))
    ("じゃ" . (z a #t))
    ("じゅ" . (z u #t))
    ("じょ" . (z o #t))
    ("ぢゃ" . (d a #t))
    ("ぢゅ" . (d u #t))
    ("ぢょ" . (d o #t))
    ("びゃ" . (b a #t))
    ("びゅ" . (b u #t))
    ("びょ" . (b o #t))
    ("ぴゃ" . (p a #t))
    ("ぴゅ" . (p u #t))
    ("ぴょ" . (p o #t))
    ("ぁ" . (l a #t))
    ("ぃ" . (l i #t))
    ("ぅ" . (l u #t))
    ("ぇ" . (l e #t))
    ("ぉ" . (l o #t))
    ("ー" . (#f - #f))))

(define (vowel? chr)
  (let ((chr-int (char->integer chr)))
    (and (<= 12354 chr-int 12362)
         (even? chr-int))))

(define (string->kana-list str)
  (let loop ((lst (string->list str)) (cont identity))
    (if (null? lst)
        (cont '())
        (if (and (not (null? (cdr lst)))
                 (any (cut eqv? (cadr lst) <>) (string->list "ゃゅょ")))
            (loop (cddr lst)
                  (lambda (x)
		    (cont
		     (cons
		      (apply kana
			     (cdr (assoc (string (car lst) (cadr lst))
					 kana-je)))
		      x))))
            (loop (cdr lst)
                  (lambda (x)
		    (cont
		     (cons
		      (apply kana (cdr (assoc (string (car lst)) kana-je)))
		      x))))))))

(define (kana->string kana)
  (let ((chr-lst
	 (rassoc (list (consonant kana) (vowel kana) (gliding? kana))
		 kana-je)))
    (if chr-lst (car chr-lst))))

(define (str-map proc str)
  (map proc (string->list str)))

(define (run-mecab args input)
  (let ((p (run-process
	    `(mecab ,@args)
	    :wait #t
	    :redirects `((<< 0 ,input) (>> 1 out)))))
    (port->string (process-output p 'out))))

(define (yomi-alist input)
  (let ((input (regexp-replace-all #/\w+/
				   input
				   "")))
    (read-from-string
     (string-append/shared
      "("
      (regexp-replace-all #/\n|EOS|dummy/
			  (run-mecab
			   '("--node-format=(\"%m\"\\s\"%f[7]\"\\s\"%H\")\\s")
			   input)
			  "")
      ")"))))

(define (kata->hira str)
  (list->string
   (str-map (lambda (x) (integer->char (- (char->integer x) 96))) str)))

(random-source-randomize! default-random-source)

(define (random n)
  (random-integer n))

(define (random-bool . prob)
  (let ((prob (if (null? prob) 2 (car prob))))
    (= (random prob) 0)))

(define (mappend fn . lsts)
  (apply append (apply map fn lsts)))

(define (flatten x)
  (cond ((null? x) '())
	((not (pair? x)) (list x))
	(else (append (flatten (car x))
		      (flatten (cdr x))))))

(define (change-cnsnnt-list kana-type)
  (if (string= (kana->string kana-type) "ん")
      (list kana-type)
      (if (memq (vowel kana-type) vwl-gldng)
	  (mappend
	   (lambda (gldng)
	     (let ((cnsnnt (if gldng cnsnnt-gldng cnsnnt-nongldng)))
	       (map
		(lambda (n)
		  (kana (list-ref cnsnnt n)
			(vowel kana-type)
			gldng))
		(iota (length cnsnnt)))))
	   '(#f #t))
	  (map
	   (lambda (n)
	     (kana (list-ref cnsnnt-nongldng n)
		   (vowel kana-type)
		   (gliding? kana-type)))
	   (iota (length cnsnnt-nongldng))))))

(define (change-vwl-list kana-type n)
  )

(define (sublists lst n)
  (let ((len (length lst)))
    (let loop ((start 0) (end n) (acc1 '()) (acc2 '()))
      (if (> end len)
	  (values (reverse! acc1) (reverse! acc2))
	  (loop (+ start 1) (+ end 1)
		(cons (subseq lst start end) acc1)
		(cons (list start end) acc2))))))

(define (make-word lofl)
  (define (rec lsts pos end result)
    (if (= pos end)
	(apply string-append
	       (map kana->string (reverse result)))
	(let ((lst (list-ref lsts pos)))
	  (list-ec (: i 0 (length lst))
		   (rec lsts (+ 1 pos) end
			(cons (list-ref lst i) result))))))
  (rec lofl 0 (length lofl) '()))

(define (sentence->list-kl str)
  (let ((alst (yomi-alist str)))
    (values
     (map car
	  alst)
     (map string->kana-list
	  (map (lambda (x) (kata->hira (list-ref x 1)))
	       alst))
     (map (lambda (x)
	    (regexp-replace-all
	     #/,.+/
	     (list-ref x 2)
	     ""))
	  alst))))

(define (change-combi kana-list change-fn)
  (map (lambda (y) (change-fn y)) kana-list))

(define (shuffle-kana kana-list)
  (permutations kana-list))

(define (rand-ref lst)
  (list-ref lst (random (length lst))))

(define (accum-cost word)
  (last
   (read-from-string
    (string-append/shared
     "("
     (regexp-replace-all
      #/\sEOS\n/
      (run-mecab '("--node-format=%pc\\s") word)
      "")
     ")"))))

(define (init-conv-hash)
  (current-directory "/home/stibear/SKK/")
  (call-with-input-file "SKK-JISYO.txt"
    (lambda (x)
      (let loop ((line (read-line x)))
	(if (eof-object? line)
	    #f
	    (let ((matched (#/^[ぁ-ん]+/ line)))
	      (hash-table-push!
	       conv-hash
	       (rxmatch-substring matched)
	       ($ generator->list
		  $ gmap (cut rxmatch-substring <> 1)
		  $ grxmatch kanji-match (rxmatch-after matched)))
	      (loop (read-line x))))))))

(define (convert str)
  (if (hash-table-exists? conv-hash str)
      (hash-table-get conv-hash str)
      '()))

(define (noun-choose str)
  (rand-ref
   (letrec ((loop
	     (lambda (i lst1 lst2 lst3)
	       (if (null? lst1)
		   '()
		   (if (equal? (car lst3) "名詞")
		       (cons (cons (car lst1) (car lst2))
			     (loop (+ i 1)
				   (cdr lst1)
				   (cdr lst2)
				   (cdr lst3)))
		       (loop (+ i 1)
			     (cdr lst1)
			     (cdr lst2)
			     (cdr lst3)))))))
     (apply loop
	    0
	    (values->list
	     (sentence->list-kl str))))))

(define (insert-kana kana-list)
  (mappend
   (lambda (n)
     (call-with-values
	 (lambda ()
	   (split-at kana-list n))
       (lambda (a b)
	 (let loop ((i 0) (acm '()))
	   (if (= 118 i)
	       acm
	       (loop (+ i 1)
		     (cons
		      (append
		       a
		       (list
			(list-ref
			 (map (lambda (x)
				(apply kana x))
			      (map cdr kana-je))
			 i))
		       b)
		      acm)))))))
   (iota (length kana-list))))

(init-conv-hash)

(define methods
  (list
   (lambda (str)
     (let ((choice (noun-choose str)))
       (map (lambda (x)
	      (regexp-replace-all
	       (string->regexp (car choice))
	       str
	       x))
	    ($ delete-duplicates
	       $ flatten
	       $ filter values
	       $ map convert
	       $ flatten
	       (make-word
		(change-combi
		 (cdr choice)
		 change-cnsnnt-list))))))
   (lambda (str)
     (let ((choice (noun-choose str)))
       (map (lambda (x)
	      (regexp-replace-all
	       (string->regexp (car choice))
	       str
	       x))
	    ($ delete-duplicates
	       $ flatten
	       $ filter values
	       $ map convert
	       (map
		(lambda (x)
		  (apply string-append/shared (map kana->string x)))
		(shuffle-kana
		 (cdr choice)))))))
   (lambda (str)
     (let ((choice (noun-choose str)))
       (map (lambda (x)
	      (regexp-replace-all
	       (string->regexp (car choice))
	       str
	       x))
	    ($ delete-duplicates
	       $ flatten
	       $ filter values
	       $ map convert
	       $ flatten
	       (make-word
		(change-combi
		 (cdr choice)
		 (lambda (x)
		   (if (or (random-bool 3) (random-bool 3))
		       (change-cnsnnt-list x)
		       (list x)))))))))
   (lambda (str)
     (let ((choice (noun-choose str)))
       (map (lambda (x)
	      (regexp-replace-all
	       (string->regexp (car choice))
	       str
	       x))
	    ($ delete-duplicates
	       $ flatten
	       $ filter values
	       $ map convert
	       $ map (lambda (x) (apply string-append/shared x))
	       (map (lambda (x)
		      (map kana->string x))
		    (insert-kana (cdr choice)))))))))

(define (main args)
  (let loop ((d-lst ((list-ref methods (random 4)) (list-ref args 1)))
	     (counter 0))
    (if (and (not (null? d-lst))
	    (< counter 8))
	(write d-lst)
	(loop ((list-ref methods (random 4)) (list-ref args 1))
	      (+ counter 1)))
    (newline)))
