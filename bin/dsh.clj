#!/usr/bin/env bb
;; dsh wrapper (babashka): adds a `list` subcommand, delegates everything
;; else to the real dsh on PATH. Install by symlinking this file as `dsh`
;; somewhere earlier in PATH than the real one, e.g.:
;;
;;   ln -s /home/lucie/dotnixes/bin/dsh.clj ~/.local/bin/dsh
;;
;; `dsh list` prints every profile under $DSH_HOME/profiles (a directory
;; with a package.json — the shared node_modules workspace is skipped).

(require '[babashka.fs :as fs]
         '[babashka.process :as p]
         '[clojure.string :as str])

(defn- self-path []
  (some-> (System/getProperty "babashka.file") fs/real-path))

(defn- real-dsh []
  "First `dsh` on PATH that isn't this script (avoids self-recursion)."
  (let [self (self-path)]
    (->> (str/split (or (System/getenv "PATH") "") #":")
         (remove str/blank?)
         (keep (fn [dir]
                 (let [candidate (fs/path dir "dsh")]
                   (when (and (fs/exists? candidate)
                              (not= (fs/real-path candidate) self))
                     (str candidate)))))
         first)))

(defn- list-profiles []
  (let [home (or (System/getenv "DSH_HOME")
                 (str (System/getProperty "user.home") "/.dsh"))
        profiles-dir (fs/path home "profiles")]
    (if-not (fs/exists? profiles-dir)
      (binding [*out* *err*]
        (println (str "dsh: no profiles directory at " profiles-dir)))
      (->> (fs/list-dir profiles-dir)
           (filter fs/directory?)
           (filter #(fs/exists? (fs/path % "package.json")))
           (sort-by fs/file-name)
           (run! #(println (fs/file-name %)))))))

(defn -main [& args]
  (if (= "list" (first args))
    (list-profiles)
    (if-let [dsh (real-dsh)]
      (apply p/exec dsh args)
      (do (binding [*out* *err*]
            (println "dsh: real dsh not found on PATH"))
          (System/exit 127)))))

;; bb does not auto-invoke -main for plain script files; call it explicitly.
(apply -main *command-line-args*)
