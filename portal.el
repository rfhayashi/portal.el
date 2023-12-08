;;; -*- lexical-binding: t; -*-

(require 'parseedn)

(defconst portal--dir (file-name-directory (or load-file-name buffer-file-name)))

(defvar portal-sessions nil)

(defvar portal-current)

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
  (process-send-string portal (concat (parseedn-print-str (portal-datafy command)) "\n")))

(defun portal-tap (val &optional portal)
  (portal--send-command (portal--the portal) `(:command :tap :value ,val))
  val)

(defun portal-clear (&optional portal)
  (interactive)
  (portal--send-command (portal--the portal) `(:command :clear)))

(defun portal-reset (val &optional portal)
  (portal--send-command (portal--the portal) `(:command :reset :value ,val)))

(defun portal-close (&optional portal)
  (interactive)
  (let ((p (portal--the portal)))
    (process-send-eof p)
    (setq portal-sessions (remove p portal-sessions))
    (setq portal-current (car portal-sessions))))

(provide 'portal)
