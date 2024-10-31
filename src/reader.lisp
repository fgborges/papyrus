(defpackage #:papyrus/src/reader
  (:use #:cl)
  (:export #:md-reader #:org-reader #:pod-reader))
(in-package #:papyrus/src/reader)

(defun <? (&rest args)
  "Return T if the arguments are in increasing order.
   If any argument is NIL, it is treated as positive infinity."
  (flet ((nil-to-inf (x) (or x most-positive-fixnum)))
    (apply #'< (mapcar #'nil-to-inf args))))

(defun org-reader (s a)
  (declare (ignore a))
  (do ((line (read-line s nil nil) (read-line s nil nil))
       (buffer nil)
       (codeblock nil))
      ((not line) (read-from-string (format nil "(progn ~{~a~%~})" (reverse buffer))))
    (cond ((<? (search "#+BEGIN_SRC" line) 1 (search "lisp" line) (search ":tangle" line) (search "yes" line) most-positive-fixnum)
           (setq codeblock t))
          ((<? (search "#+END_SRC" line) 1) (setq codeblock nil))
          (codeblock (push line buffer)))))

(defun md-reader (s a)
  (declare (ignore a))
  (do ((line (read-line s nil nil) (read-line s nil nil))
       (buffer nil)
       (codeblock nil))
      ((not line)
       (progn
         (print (reverse buffer))
         (read-from-string (format nil "(progn ~{~a~%~})" (reverse buffer)))))
    (cond ((<? (search "```lisp" line) 1) (setq codeblock t))
          ((<? (search "```" line) 1) (setq codeblock nil))
          (codeblock (push line buffer)))))

(defun pod-reader (s a)
  (declare (ignore a))
  (do ((line (read-line s nil nil) (read-line s nil nil))
       (buffer nil)
       (codeblock t))
    ((not line) (read-from-string (format nil "(progn ~{~a~%~})" (reverse buffer))))
    (cond ((<? (search "=cut" line) 1) (setq codeblock t))
          ((<? (search "=pod" line) 1) (setq codeblock nil))
          (codeblock (push line buffer)))))
