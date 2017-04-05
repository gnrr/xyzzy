;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;;  print-mode-line-mode
;;;


#|
http://www2.ocn.ne.jp/~cheerful/script/index.html
TKI

●概要
mode-line に好きな文字や拡張情報を表示させます。
(minor-mode)

●使い方
(load-library "print-mode-line-mode")
で読み込み
setq で mode-line-formatを設定してから
M-x print-mode-line-mode
で立ち上げます。

○実行時
あとは この「マイナーモードを呼ぶ前」に 標準の mode-line-formatを修正してください。

変更するときも マイナーモードオフにしてから mode-line-formatを設定し
マイナーモードをオンにします。
(間違えちゃっても大した影響はないけど、うまく反映されない時もある。)

マイナーモード表示名：「@」にしました。

○フォーマットサンプル

;標準：拡張なしだとすると、
(setq mode-line-format "[%i] %* %b (%M) [%k:%l] %P %f")

;設定例
(setq mode-line-format "[%i]%b(%M)[%k:%l] %*,%T,%isech%PL(%/％:%pts) %ps %f")

;カーソル位置％と文字数表示
(setq mode-line-format "[%i] %* %b (%M) |%/％,  %n |  [%k:%l] %P %f")

;グリニッジ時間表示
(setq mode-line-format "[%i] %* %b (%M) |%2ATIME|  [%k:%l] %P %f")
(setq *second-area-timezone* -18) ;多分・・
(setq *second-area-time-format* "%m/%d(%v)) %H:%M")



○拡張フォーマット
%/      : カーソル位置が バッファ全体の何％の位置にあるか
%PL     : 表示ライン桁数 論理行において、桁数も見た目ではなく論理行
%Px     : 表示ライン桁数(x,y形式)
%pts    : カーソル位置
%ps     : m マークの位置方向 ,  lm 最後に修正位置の方向
%mpts   : カーソル最大位置  ほぼ %s かな
%s      : バッファーサイズ
%c      : 文字数(改行を除く)
%w      : 単語数 (スペース区切りなど、日本語は無理)
%n      : 改行数
%fd     : ファイル更新日時 (フォーマット：*print-mode-time-format*)
%fh     : ファイル更新時 (フォーマット：*print-mode-time-format-sub*)
%2ATIME : 第二地域日時表示 (*second-area-time-format*,*second-area-timezone* 参照)
%fc     : fill-column数
%lc     : ラストコマンド last-command
%tc     : コマンド this-command
%machine: マシン名
%T      : t  :trace-on-error?
         as :auto-save?
         l  :lock-file?
          * :ロック済みか
         b  :back-up?
          + :back-up-always
         u  :undo可能?
         ld :ldoc
         pr :paren 
(%isech : r  : isearch-deco regex
         c  : isearch-deco case-foldp
         d  : isearch-deco coloring
          * : isearch-deco coloring left  ) ・・・イマイチ


それ以外にも *print-mode-line-mode-list*に設定すれば簡単に拡張できます。作るのは大変だけど
・お天気
・メール着信
・借金時計
・時刻スケジュール
・時報
・CPU情報、バッテリー
・%cd    : カウントダウン とか
・%pd    : 経過日   とか

追加例：
(push (list (list "%XYZ" 'hogehoge-func)) *print-mode-line-mode-list*)


・標準フォーマットについては、更新履歴：Version 0.2.1.153参照
http://www.jsdlab.co.jp/~kei/download/OChangeLog.html

○制限
独自のバッファローカル設定(den8とか？)しているとどうなるか試していません。

OFFにしていると標準mode-line-formatからゴミが見えるので
適当に設定しなおしてください。


○一応・・・
バッファーごとにしてみました。
(これだけでも結構苦労しました)

●設計内容
;mode-line-formatに表示する
;post-command-hook を活用する。
;文字をリプレースする。

●履歴

2010/8/14 拡張ライブラリをサンプルとして作成
2010/8/14 mode-line-modeと被るけどUIを使いやすくした。

2002/1/10 新規作成

以上


|#
;----------------------------------------
;ベースライブラリ

(provide "print-mode-line-mode")

(in-package "editor")

(export '(
          print-mode-line-mode
          *print-mode-line-mode-all-format* 

          *print-mode-line-mode-list*  
          *print-mode-time-format* 
          *print-mode-time-format-sub*
          *second-area-time-format*
          *second-area-timezone*

          ))

;カスタマイズ可能
;--基本
;*print-mode-line-mode-list* もカスタマイズ可能

;--拡張おまけライブラリ
(defvar *print-mode-time-format* "%Y/%m/%d %H:%M")
(defvar *print-mode-time-format-sub* "%H:%M %S")
(defvar *second-area-timezone* -18) ;日本は -9  (？  グリニッジは-18?)
(defvar *second-area-time-format* "%m/%d(%v)) %H:%M")




;内部用
;バッファ毎に宣言しない
(defvar-local *print-mode-line-mode* nil)
;変換前の mode-line-format ：ON時に設定、 変換時にこれから変換する。
(defvar-local *print-mode-line-mode-default-string* "")
;変換前の mode-line-format 全体用：   ON時 かつ 1回目の起動時に設定 
;  mode-line-formatがローカルでない場合デフォルトとして使い、 
;  print-mode-line-modeにおいて変換後のmode-line-formatで表示がおかしくなるのを防ぐ
(defvar *print-mode-line-mode-all-format*)

;print-mode-line-mode の起動バッファ数
(defvar *print-mode-line-mode-num* 0)

;メインのトグルコマンド
(defun print-mode-line-mode (&optional (arg nil sv))
  (interactive)
  (toggle-mode '*print-mode-line-mode* arg sv)

  (if *print-mode-line-mode*
      ;ON
    (progn
      ;概要(整理・・)
      ;・デフォルトstringの設定
      ;=1の時
      ;  mode-line-formatから
      ;  all-formatへも
      ;  ・hook設定
      ;/=1の時
      ;  all-formatから


      (setq *print-mode-line-mode-num* (+ 1  *print-mode-line-mode-num*))

      ;buffer-localにするつもり
      (if (not (local-variable-p 'mode-line-format))
          (progn
           (defvar-local mode-line-format mode-line-format)))

      (cond  ((= 1 *print-mode-line-mode-num*)
              (setq *print-mode-line-mode-all-format* mode-line-format
                     *print-mode-line-mode-default-string* mode-line-format)
               (add-hook '*post-command-hook* 'mode-line-extention))
             (t
              (if (local-variable-p 'mode-line-format)
                  (setq *print-mode-line-mode-default-string* mode-line-format)
                  (setq *print-mode-line-mode-default-string* *print-mode-line-mode-all-format*
                   mode-line-format *print-mode-line-mode-all-format*)))))

    ;OFF
      (progn
        (setq mode-line-format *print-mode-line-mode-default-string*
              *print-mode-line-mode-default-string* *print-mode-line-mode-all-format*
              *print-mode-line-mode-num* (- *print-mode-line-mode-num* 1))
        (if (<= 0 *print-mode-line-mode-num*)
            (progn
              (setq *print-mode-line-mode-num* 0)
              (delete-hook '*post-command-hook* 'mode-line-extention)))))
   (update-mode-line t))

;mode line 置き換え(post-hookで呼ばれる)
(defun mode-line-extention ()

  ;すべてのところで手動トグルはめんどいのでONを自動化する。
  ;post-hookでどこかがminor-だと呼ばれる前提
  (if (not *print-mode-line-mode*)
      ;local設定がある場合自動ONしない
      (if (not (local-variable-p 'mode-line-format))(print-mode-line-mode t)))

 (let ((flag nil)(num 0)(label *print-mode-line-mode-default-string*))
   ;format置き換え処理
   (dolist (item *print-mode-line-mode-list*)
     (setq num (+ 1 num))
     (if (string-match (car item) label)
       (progn
        (setq label (substitute-string label (car item) 
                                (funcall (cadr item))))
        (setq flag t))))

   ;表示更新update、TODO?更新がなかったらoffにしようか？
  (if flag 
   (progn
     (setq mode-line-format label)
    (update-mode-line (selected-buffer))))))

(pushnew '(*print-mode-line-mode* . "@") *minor-mode-alist* :key #'car)
;(delete '*print-mode-line-mode* *minor-mode-alist* :test #'(lambda (x y) (eq x (car y))))

;----------------------------------------
;拡張おまけライブラリ

;標準
;%*, %#*, %r, %#r, %p, %v, %h, %#h, %b, %f, %#f, %F, %#F, %M, %m, %k, %l, %i, %P

(setq *print-mode-line-mode-list*
 (list
  (list "%/" 'ed::mode-line-string-pos-per)
  (list "%PL" 'ed::mode-line-string-logical-line-column)
  (list "%Px" 'ed::mode-line-string-xy-line-column)
  (list "%pts" 'ed::mode-line-string-point)
  (list "%ps" 'ed::mode-line-string-positions)
  (list "%mpts" 'ed::mode-line-string-max-point);narrowing の時はNG?
  (list "%s" 'ed::mode-line-string-buffer-size)
  (list "%c" 'ed::mode-line-string-max-point-non-cr)
  (list "%w" 'ed::mode-line-string-count-word)
  (list "%n" 'ed::mode-line-string-count-cr)
  (list "%fd" 'ed::mode-line-string-buffer-file-date)
  (list "%fh" 'ed::mode-line-string-buffer-file-time)
  (list "%2ATIME" 'ed::mode-line-string-second-area-time)
  (list "%fc" 'ed::mode-line-string-fill-column)
  (list "%lc" 'ed::mode-line-string-last-command)
  (list "%tc" 'ed::mode-line-string-this-command)
  (list "%machine" 'ed::mode-line-string-machine)
  (list "%T" 'ed::mode-line-string-toggler)
  (list "%isech" 'ed::mode-line-string-toggler-isearch-deco)
   ))


(defun mode-line-string-pos-per ()
 (format nil "~A" (floor (/ (* (current-line-number) 100)  (buffer-lines)))))
 ;;%を表示させたい場合は %%で、あと後ろの文字が変換されないように注意

(defun mode-line-string-logical-line-column ()
  (format nil "~5@A:~4A" (current-line-number)(current-column)))

(defun mode-line-string-xy-line-column ()
 (if (buffer-line-number-mode(selected-buffer))
     (format nil "~4@A,~5A" (current-virtual-column)(current-virtual-line-number))
  (format nil "~4@A,~5A" (current-column)(current-line-number))))

(defun mode-line-string-point ()
  (format nil "~A" (point)))

(defun mode-line-string-max-point ()
  (format nil "~A" (point-max)))

(defun mode-line-string-buffer-size ()
  (format nil "~A" (buffer-size)))

(defun mode-line-string-max-point-non-cr ()
 (save-excursion
  (let ((cr-num))
   (goto-char (point-min))
   (setq cr-num (count-matches "\n" nil t))
   (format nil "~A" (- (point-max) cr-num)))))

(defun mode-line-string-count-word ()
 (save-excursion
  (let ((WB-num)(WB-num-m)))
   (goto-char (point-min))
   (setq WB-num (count-matches "\\b" nil t))
   (goto-char (point-min))
   (setq WB-num-m (count-matches "-\n+" nil t))
   (format nil "~A"  (- (floor (/ WB-num 2))WB-num-m))))

(defun mode-line-string-count-cr ()
 (save-excursion
  (let ((cr-num))
   (goto-char (point-min))
   (setq cr-num (count-matches "\n" nil t))
   (format nil "~A" (+ 1 cr-num)))))


(defun mode-line-string-buffer-file-date ()
 (let ((str ""))
  (ignore-errors
   (setq str  (format-date-string *print-mode-time-format* (file-write-time (get-buffer-file-name(selected-buffer))))))
   str))

(defun mode-line-string-buffer-file-time ()
 (let ((str ""))
  (ignore-errors
   (setq str (format-date-string *print-mode-time-format* (file-write-time (get-buffer-file-name(selected-buffer))))))
   str))

(defun mode-line-string-second-area-time ()
  (let ((y)(m)(d)(h)(mi)(s)(w)(temp)(tz))
   (multiple-value-setq (s mi h d m y w temp tz) (decode-universal-time (get-universal-time) ))
    (format nil "~A" (format-date-string *second-area-time-format*  (encode-universal-time s mi h d m y ed::*second-area-timezone*)))))

(defun mode-line-string-fill-column ()
  (format nil "~A" fill-column))

(defun mode-line-string-last-command ()
  (format nil "~A" *last-command*))

(defun mode-line-string-this-command ()
  (format nil "~A" *this-command*))

(defun mode-line-string-toggler ()
  (format nil "~A~A~A~A~A~A~A" 
          (if  si::*trace-on-error* "t" "-")
          (if  auto-save "as" "--")
          (concat 
           (if  lock-file "l" "-")
           (if  (file-locked-p) "*" "-"))
          (concat 
           (if  make-backup-files "b" "-")
           (if  make-backup-file-always "+" "-"))
          (concat 
           (if  (buffer-can-undo-p(selected-buffer)) "u" "-")
;           (format nil "~A" kept-undo-information)
           )

          (if (ignore-errors (not *ldoc-status*))  "--" "ld")
          (if (ignore-errors (not *paren-status*)) "--" "pr" )
          ))

;リアルタイムに変わらない
(defun mode-line-string-toggler-isearch-deco ()
 (let ((str ""))
    (setq str 
          (format nil "~A~A~A~A" 
                  (if  *case-fold-search* "c" "-")
                  (if  ed::*isearch-regexp* "r" "-")
                  (if  ed::*isearch-deco-ignore* "-" "d")
                  (if  ed::*isearch-deco-refresh-p* "*" "-")
                  ))
   str))

(defun mode-line-string-positions ()
 (let ((str "-")(strlm "-"))
    (format nil "m:~A lm:~A" 
            (progn
              (ignore-errors
               (setq str (if (mark t) (if (< (point)(mark t)) "↓" "↑") "-")))
             str)
     (progn
       (ignore-errors
        (setq strlm
              (if (< (point)(last-modified-point)) "↓" "↑")))
      strlm))))

(defun mode-line-string-machine ()
  (machine-name))

