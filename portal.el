;;; -*- lexical-binding: t; -*-

(require 'parseedn)

(defconst portal--dir (file-name-directory (or load-file-name buffer-file-name)))

(defvar portal-sessions nil)

(defvar portal-current nil)

(defun portal--the (portal)
  (or portal portal-current (portal-open)))

(defun portal-open ()
  (interactive)
  (let ((default-directory (concat portal--dir "bb")))
    (let ((p (make-process :name "portal" :buffer "*portal-log*" :command '("bb" "portal.clj"))))
      (add-to-list 'portal-sessions p)
      (setq portal-current p)
      p)))

(cl-defgeneric portal-datafy (object)
  (prin1-to-string object))

(cl-defmethod portal-datafy ((object number)) object)
(cl-defmethod portal-datafy ((object string)) object)
(cl-defmethod portal-datafy ((object symbol)) object)
(cl-defmethod portal-datafy ((object vector))
  (seq-into (seq-map 'portal-datafy object) 'vector))
(cl-defmethod portal-datafy ((object hash-table))
  (let ((result (make-hash-table)))
    (maphash
     (lambda (key val)
       (puthash (portal-datafy key) (portal-datafy val) result))
     object)
    result))
(cl-defmethod portal-datafy ((object cons))
  (cons (portal-datafy (car object))
        (portal-datafy (cdr object))))

(defun portal--send-command (portal command)
  (process-send-string portal (parseedn-print-str (portal-datafy command)))
  (process-send-string portal "\n"))

(defun portal-tap (val &optional meta portal)
  (portal--send-command (portal--the portal) `(:command :tap :value ,val :meta ,meta))
  val)

(defun portal-clear (&optional portal)
  (interactive)
  (portal--send-command (portal--the portal) `(:command :clear)))

(defun portal-docs (&optional portal)
  (interactive)
  (portal--send-command (portal--the portal) `(:command :docs)))

(defun portal-reset (val &optional meta portal)
  (portal--send-command (portal--the portal) `(:command :reset :value ,val :meta ,meta)))

(defun portal-close (&optional portal)
  (interactive)
  (let ((p (portal--the portal)))
    (process-send-eof p)
    (setq portal-sessions (remove p portal-sessions))
    (setq portal-current (car portal-sessions))))

(cl-defmethod portal-datafy ((object ert-test-failed))
  (list :messages (ert-test-result-messages object)
        :duration (ert-test-result-duration object)
        :condition (ert-test-result-with-condition-condition object)))

(cl-defmethod portal-datafy ((object ert-test-passed))
  (list :messages (ert-test-result-messages object)))

(defun portal-run-ert-test-at-point ()
  (interactive)
  (eval-defun nil)
  (when-let ((test-sym (ert-test-at-point)))
    (let ((test (ert-get-test test-sym)))
      (let ((result (ert-run-test test)))
        (portal-tap result)
        (message (prin1-to-string (type-of result)))))))

(provide 'portal)
