;;;; ulid.asd

(asdf:defsystem #:net.bardcode.ulid
  :description "A simple implementation of ULID in Common Lisp"
  :author "mikel evins <mikel@evins.net>"
  :license  "Apache 2.0"
  :version "0.0.1"
  :serial t
  :depends-on (:cl-intbytes :ironclad)
  :components ((:file "package")
               (:file "ulid")))

#+nil (ql:quickload :net.bardcode.ulid)
