;;;; ulid.lisp

(in-package #:net.bardcode.ulid)

;;; Crockford's Base32
(defvar *base32-characters* "0123456789ABCDEFGHJKMNPQRSTVWXYZ")
(defvar +seconds-between-lisp-epoch-and-unix-epoch+ 2208988800)
(defvar +48-set-bits+ #b111111111111111111111111111111111111111111111111)
(defvar +80-set-bits+ #b11111111111111111111111111111111111111111111111111111111111111111111111111111111)
(defvar +128-set-bits+ #xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

(defmethod any ((s sequence) &optional (prng ironclad:*prng*))
  (elt s (ironclad:strong-random (length s) prng)))

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

(defun get-ulid-timestamp-bytes (&optional time-milliseconds)
  (reverse (cl-intbytes:int->octets (or time-milliseconds
                               (milliseconds-now))
                           6)))

#+nil (get-ulid-timestamp-bytes)

(defun get-ulid-random-bytes (&optional (prng ironclad:*prng*))
  (cl-intbytes:int->octets (ironclad:strong-random +80-set-bits+ prng)
                           10))

#+nil (get-ulid-random-bytes)

;;; binary ulid, returned as a vector of bytes
;;; create as time bytes + random bytes
(defun make-ulid (&optional milliseconds)
  (let* ((mss-bytes (get-ulid-timestamp-bytes milliseconds))
         (random-bytes (get-ulid-random-bytes)))
    (concatenate 'vector mss-bytes random-bytes)))

#+nil (time (loop for i from 0 below 1000000 do (make-ulid)))

(defun ulid->hex-string (ulid)
  (with-output-to-string (out)
    (loop for b across ulid
          do (format out "~(~2,'0x~)" b))))

#+nil (length (ulid->hex-string (make-ulid)))
