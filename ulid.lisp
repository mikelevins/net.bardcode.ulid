;;;; ulid.lisp

(in-package #:net.bardcode.ulid)

;;; Crockford's Base32
(defvar *base32-characters* "0123456789ABCDEFGHJKMNPQRSTVWXYZ")
(defvar *ulid-random-state* nil)
(defvar +seconds-between-lisp-epoch-and-unix-epoch+ 2208988800)

(defmethod any ((s sequence) &optional (random-state *random-state*))
  (elt s (random (length s) random-state)))

(defun milliseconds-now ()
  #+sbcl
  (multiple-value-bind (sec microsec) (sb-ext:get-time-of-day)
    (+ (* 1000 sec) (round (/ microsec 1000))))
  ;; TODO: add cases for other lisps that yield results with millisecond precision
  ;;       the below is to the nearest second
  #-sbcl
  (* (- (get-universal-time)
        +seconds-between-lisp-epoch-and-unix-epoch+)
     1000))

(defun milliseconds->base32 (ms)
  (let ((bitstring (format nil "~2,50,'0r" ms)))
    (loop for start from 0 upto 45 by 5
          for end = (+ start 5)
          collect (let ((i (parse-integer (subseq bitstring start end) :radix 2)))
                    (elt *base32-characters* i)))))

(defun make-ulid (&optional milliseconds)
  (concatenate 'string
               (milliseconds->base32 (or milliseconds (milliseconds-now)))
               (progn (unless *ulid-random-state*
                        (setf *ulid-random-state* (make-random-state t)))
                      (loop for i from 0 upto 15
                            collect (any *base32-characters* *ulid-random-state*)))))

#+nil (time (loop for i from 0 below 1000000 do (make-ulid)))
