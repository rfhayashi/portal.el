(require '[clojure.edn :as edn])
(require '[portal.api :as p])

(def portal (p/open))

(defmulti process-command :command)

(defmethod process-command :reset
  [{:keys [meta value]}]
  (reset! portal (with-meta value meta)))

(defmethod process-command :tap
  [{:keys [meta value]}]
  (p/submit (with-meta value meta)))

(defmethod process-command :docs
  [_]
  (p/docs))

(defmethod process-command :clear
  [_]
  (p/clear portal))

(loop []
  (let [command (edn/read {:eof :eof} *in*)]
    (prn command)
    (if (= :eof command)
      (p/close portal)
      (let [result (process-command command)]
        (prn {:result result})
        (recur)))))
