;; User pack init file
;;
;; Use this file to initiate the pack configuration.
;; See README for more information.

;; Load bindings config
(live-load-config-file "bindings.el")

;; Load frame settings
(when (display-graphic-p)
  (live-load-config-file "frame.el"))
