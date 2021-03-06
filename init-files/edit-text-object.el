;;; derived from http://superuser.com/questions/124246/emacs-equivalent-to-vim-ci

;;; Re-create ci" ca"...
(defun seek-backward-to-char (chr)
 "Seek backwards to a character"
 (interactive "cSeek back to char: ")
 (while (not (= (char-after) chr))
  (forward-char -1)))

(defun point-of-left-piece ()
 (setq old-point (point))
 (call-interactively 'seek-backward-to-char)
 (setq return-value (point))
 (goto-char old-point)
 (princ return-value))

(setq char-pairs
 '(( ?\" . ?\" )
   ( ?\' . ?\' )
   ( ?\( . ?\) )
   ( ?\[ . ?\] )
   ( ?\{ . ?\} )
   ( ?<  . ?>  )
   ( ?/  . ?/  )
   ( ?$  . ?$  )
   ( ?-  . ?-  )
   ( ?_  . ?_  )
   ( ?`  . ?`  )
   ( ?\u0020  . ?\u0020  ) ;;; hankaku space
   ))



(defun ieremii-move-left-to-char (char)
 (if (= (char-after (point)) char)
  ()
  (progn
   (forward-char -1)
   (ieremii-move-left-to-char char))))



(defun ieremii-move-right-to-char (char)
 (if (= (char-after (point)) char)
  ()
  (progn
   (forward-char 1)
   (ieremii-move-right-to-char char))))



(defun mark-all-pair (a-char)
 (interactive "cmark all pair: ")
 (setq pair (get-char-pair a-char))
 (setq left (car pair))
 (setq right (cdr pair))
 (ieremii-move-left-to-char left)
 (set-mark-command nil)
 (ieremii-move-right-to-char right)
 (forward-char 1))



(defun get-char-pair (chr)
 (let ((result ()))
  (dolist (x char-pairs)
   (setq start (car x))
   (setq end (cdr x))
   (when (or (= chr start) (= chr end))
    (setq result x)))
  result))

(defun get-start-char (chr)
 (car (get-char-pair chr)))
(defun get-end-char (chr)
 (cdr (get-char-pair chr)))

(defun seek-to-matching-char (start end count)
 (while (> count 0)
  (if (= (following-char) end)
   (setq count (- count 1))
   (if (= (following-char) start)
    (setq count (+ count 1))))
  (forward-char 1)))

(defun seek-backward-to-matching-char (start end count)
 (if (= (following-char) end)
  (forward-char -1))
 (while (> count 0)
  (if (= (following-char) start)
   (setq count (- count 1))
   (if (= (following-char) end)
    (setq count (+ count 1))))
  (if (> count 0)
   (forward-char -1))))

(defun delete-between-pair (char)
 "Delete in between the given pair"
 (interactive "cDelete between char: ")
 (seek-backward-to-matching-char (get-start-char char) (get-end-char char) 1)
 (forward-char 1)
 (setq mark (point))
 (seek-to-matching-char (get-start-char char) (get-end-char char) 1)
 (forward-char -1)
 (kill-region mark (point)))

(defun delete-all-pair (char)
 "Delete in between the given pair and the characters"
 (interactive "cDelete all char: ")
 (seek-backward-to-matching-char (get-start-char char) (get-end-char char) 1)
 (setq mark (point))
 (forward-char 1)
 (seek-to-matching-char (get-start-char char) (get-end-char char) 1)
 (kill-region mark (point)))

(defun mark-between-pair (char)
 (interactive "c")
 (seek-backward-to-matching-char (get-start-char char) (get-end-char char) 1)
 (forward-char 1)
 (setq start (point))
 (set-mark-command nil)
 (seek-to-matching-char (get-start-char char) (get-end-char char) 1)
 (forward-char -1)
 (setq end (point)))



(defun mark-all-pair (char)
 (interactive "c")
 (seek-backward-to-matching-char (get-start-char char) (get-end-char char) 1)
 (setq start (point))
 (set-mark-command nil)
 (seek-to-matching-char (get-start-char char) (get-end-char char) 1)
 (forward-char -1)
 (setq end (point)))



(defun copy-between-pair ()
 (interactive)
 (call-interactively 'mark-between-pair)
 (copy-region-as-kill start end))

(defun copy-whole-buffer ()
 (interactive)
 (copy-region-as-kill (point-min) (point-max)))

(defun kill-whole-buffer ()
 (interactive)
 (kill-region (point-min) (point-max)))

(defun blank-line? ()
 (string-match "^\n$" (substring-no-properties (thing-at-point 'line))))

;;; move-to-(next|previous)-blank-line
;;; derived from http://mint.hateblo.jp/entry/2012/06/05/154009

(defun move-to-next-blank-line ()
 (interactive)
 (progn (forward-line 1)
  (if (or
       (blank-line?)
       (= (line-number-at-pos) (line-number-at-pos (point-max))))
   (end-of-line)
   (move-to-next-blank-line))))

(defun move-to-previous-blank-line ()
 (interactive)
 (progn (forward-line -1)
  (if (or
       (blank-line?)
       (= (line-number-at-pos) 1))
   (beginning-of-line) (move-to-previous-blank-line))))

(defun end-of-block ()
 (interactive)
 (progn
  (move-to-next-blank-line)
  (end-of-line)))




(defun beginning-of-block ()
 (interactive)
 (progn
  (move-to-previous-blank-line)
  (if (= (line-number-at-pos) 1)
   ()
   (forward-line 1))
  (beginning-of-line)))

(defun mark-block ()
 (interactive)
 (progn
  (beginning-of-block)
  (set-mark-command nil)
  (end-of-block)))

(defun copy-block ()
 (interactive)
 (progn
  (beginning-of-block)
  (setq start (point))
  (end-of-block)
  (setq end (point))
  (copy-region-as-kill start end)))

(defun member-p (a b)
 (not (not (member a b))))



(defun beg-of-word-p ()
 (or
  (member-p
   (char-after (point))
   beger-of-word)
  (member-p
   (char-before (point))
   open-paren)))

(defun pr-bowp () (interactive)
 (princ (beg-of-word-p)))

(global-set-key (kbd "<f12>") 'pr-bowp)
(global-set-key (kbd "C-<f12>") 'move-to-close-paren)
(global-set-key (kbd "M-<f11>") 'move-to-open-paren)



(setq larges (number-sequence (string-to-char "A") (string-to-char "Z")))

(setq open-paren
 (mapcar 'string-to-char
  (list
   "("
   "["
   "{")))



(setq close-paren
 (mapcar 'string-to-char
  (list
   ")"
   "}"
   "]")))


(defun move-to-open-paren ()
 (interactive)
 (forward-char -1)
 (if (not (on-open-paren-p))
  (move-to-open-paren)))



(defun move-to-close-paren ()
 (interactive)
 (forward-char 1)
 (if (not (on-close-paren-p))
  (move-to-close-paren)))



(defun on-open-paren-p ()
 (member-p (char-after (point)) open-paren))


(defun on-close-paren-p ()
 (member-p (char-after (point)) close-paren))

(setq beger-of-word 
 (mapcar 'string-to-char 
  (list
   "-" "_" "/" ":" "'" ")" "]" "}" ">" "." "," " " "&" "@"
   "，" "．" "、" "。" "・" "？" "！" "『" "』"
   "\"" "\\" "\n")))

(setq beger-of-word (append larges beger-of-word))



(defun my-forward-word ()
 (interactive)
 (forward-char 1)
 (if (not (beg-of-word-p))
  (my-forward-word)))




(defun my-mark-word ()
 (interactive)
 (my-backward-word)
 (set-mark-command nil)
 (my-forward-word))

(defun my-backward-word ()
 (interactive)
 (forward-char -1)
 (if (bolp)
  (skip-chars-forward " \t")
  (if (not (beg-of-word-p))
   (my-backward-word))))

(defun move-to-end-of-word ()
 (interactive)
 (my-forward-word)
 (forward-char -1))

(defun ieremii-kill-word ()
 (interactive)
 (setq mark (point))
 (my-forward-word)
 (kill-region mark (point)))



(defun ieremii-backward-kill-word ()
 (interactive)
 (setq mark (point))
 (my-backward-word)
 (kill-region mark (point)))



(defun ieremii-mark (char)
 (interactive "c")
 (cond
  ((eq char ?b) (mark-block))
  ((eq char ?t) (mark-whole-buffer))
  ((eq char ?w) (my-mark-word))
  ((eq char ?l) (mark-line))
  (t (mark-between-pair char))))




(defun mark-line ()
 (interactive)
 (beginning-of-line)
 (set-mark-command nil)
 (end-of-line))



(defun copy-line (line-num)
 (interactive "nCopy line: ")
 (setq origin (point))
 (goto-line line-num)
 (beginning-of-line)
 (setq mark (point))
 (end-of-line)
 (copy-region-as-kill mark (point))
 (goto-char origin))



(defun whitespace-p ()
 (interactive)
 (member-p (char-after) (list (string-to-char " ") (string-to-char "\t"))))



(defun before-whitespace-p ()
 (interactive)
 (member-p (char-before) (list (string-to-char " ") (string-to-char "\t"))))



(defun exit-white-space ()
 (interactive)
 (if (whitespace-p)
  (progn
   (setq end-of-whitespace (cdr (bounds-of-thing-at-point 'whitespace)))
   (goto-char end-of-whitespace))))



(defun real-beginning-of-line-p ()
 (or
  (bolp)
  (and
   (before-whitespace-p)
   (not (whitespace-p)))))



(defun real-beginning-of-line ()
 (interactive)
 (while (not (real-beginning-of-line-p))
  (progn
   (forward-char -1))))

(defun exit-white-space-or-forward-word ()
 (interactive)
 (if (whitespace-p)
  (exit-white-space)
  (my-forward-word)))



(defun ieremii-kill-line ()
 (interactive)
 (if (blank-line?)
  (kill-line)
  (progn
   (setq start (point))
   (setq end (cdr (bounds-of-thing-at-point 'line)))
   (kill-region start end))))



(defun ieremii-kill-line-contents ()
 (interactive)
 (progn
  (setq start (point))
  (setq end (1- (cdr (bounds-of-thing-at-point 'line))))
  (kill-region start end)))



(defun prev-do ()
 (interactive)
 (search-backward "do"))



(defun next-end ()
 (interactive)
 (search-forward "end"))



(defun ruby-mark-block ()
 (interactive)
 (prev-do)
 (set-mark-command nil)
 (next-end))



(defun count-char (char begin end)
 (setq begin (max begin (point-min)))
 (setq end (min end (point-max)))
 (setq scanner begin)
 (setq count 0)
 (while (not (= scanner end))
  (if (= (char-after scanner) char)
   (setq count (+ count 1))
   nil)
  (setq scanner (1+ scanner)))
  count)



(defun <=> (a b)
 (cond
  ((< a b) -1)
  ((= a b) 0)
  ((> a b) 1)))



(defun balance? (char begin end)
 (setq pair (get-char-pair char))
 (setq open (car pair))
 (setq close (cdr pair))
 (setq left-pieces (count-char open begin end))
 (setq right-pieces (count-char close begin end))
 (<=> left-pieces right-pieces))



(defun widen (char begin end orientation)
 (setq left-scanner begin)
 (setq right-scanner end)
 (cond
  ((< orientation 0)
   (left-widen char begin end))
  ((= orientation 0)
   ())
  ((> orientation 0)
   (right-widen char begin end))))


(defun left-widen (char begin end)
 (setq begin (nearest char -1 (1- begin)))
 (list begin end))

;;;(left-widen ?c 100 100000)

(defun right-widen (char begin end)
 (nearest char 1 (1+ end)))



(defun nearest (char orientation init)
 (if (< init (point-min))
  (setq init (point-min))
  nil)
 (if (> init (point-max))
  (setq init (point-max))
  nil)
 (setq orientation
  (<=> orientation 0))
 (setq scanner init)
 (setq scanning-char (char-after scanner))
 (while (not (= scanning-char char))
  (setq scanning-char (char-after scanner))
  (setq scanner (+ scanner orientation)))
 (if
  (and
   (= scanner (point-min))
   (not (= scanning-char char)))
  "error"
  scanner))

;;;(nearest ?c 1 100000)



(defun balanced-pos (char init)
 (setq pair (get-char-pair char))
 (setq open (car pair))
 (setq close (cdr pair))
 (setq begin (nearest open -1 init))
 (setq end (nearest end 1 init))
 (balance? begin end)
 (list begin end))



(defun region-to-string (begin end)
 (setq str "")
 (goto-char begin)
 (while (not (= end (point)))
  (setq char (char-after (point)))
  (setq str (concat str (char-to-string char)))
  (forward-char 1))
 str)



(global-set-key (kbd "C-c i") 'delete-between-pair)
(global-set-key (kbd "C-c a") 'delete-all-pair)

(provide 'edit-text-object)
