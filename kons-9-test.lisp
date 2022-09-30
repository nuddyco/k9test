;; Simple tests for kons-9
(require :asdf)
(format t "~&Loading Kons-9..~%")
(asdf:oos 'asdf:load-op :kons-9)
(format t "~&Success loading Kons-9.~%")
(format t "~&Testing Kons-9..~%")
(asdf:oos 'asdf:test-op :kons-9)
(format t "~&Success testing Kons-9~%")
