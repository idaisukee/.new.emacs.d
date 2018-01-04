(custom-set-variables
 '(smart-compile-alist
   (quote
    ((emacs-lisp-mode emacs-lisp-byte-compile)
     (html-mode browse-url-of-buffer)
     (nxhtml-mode browse-url-of-buffer)
     (html-helper-mode browse-url-of-buffer)
     (octave-mode run-octave)
     ("\\.c\\'" . "gcc -O2 %f -lm -o %n")
     ("\\.[Cc]+[Pp]*\\'" . "g++ -O2 %f -lm -o %n")
     ("\\.m\\'" . "gcc -O2 %f -lobjc -lpthread -o %n")
     ("\\.java\\'" . "javac %f")
     ("\\.php\\'" . "php %f")
     ("\\.f90\\'" . "gfortran %f -o %n")
     ("\\.[Ff]\\'" . "gfortran %f -o %n")
     ("\\.cron\\(tab\\)?\\'" . "crontab %f")
     ("\\.tex\\'" tex-file)
     ("\\.texi\\'" . "makeinfo %f")
     ("\\.mp\\'" . "mptopdf %f")
     ("\\.pl\\'" . "perl %f")
     ("\\.py\\'" . "python %f")
     ("\\.rb\\'" . "ruby %f")
     ("\\.coffee\\'" . "coffee %f")
     ("\\.js\\'" . "node %f")
     ("\\.scm\\'" . "gosh %f")))))

(provide 'smart-compile-init)
