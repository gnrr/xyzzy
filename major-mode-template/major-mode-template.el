(provide 'majar-mode-template)

(defun majar-mode-template (name &key keyword syntax key ext)
  """
  メジャーモードのテンプレートです。
  name     メジャーモード名のシンボルです。xxx-mode の xxx にあたります。
           またモード表示行の括弧内には Xxx（nstring-capitalize name) を
           表示します。
  keyword  t ならばファイル名 Xxx をキーワードファイルとして読み込みます。
  syntax   シンタックステーブルを渡すとそれを利用します。
  key      キーマップを渡すとそれを利用します。
  ext      正規表現を渡すとマッチするファイル名とモードを関連付けます。
  """
  (flet ( 
    ; フォーマットに従ってシンボルを生成する関数
    (symbol (f) (intern (format nil f (symbol-name name)))))
    (let* (
      (mode (symbol "~A-mode"))
      (mode-name (nstring-capitalize (format nil "~A" (symbol-name name))))
      (mode-hook (symbol "*~A-mode-hook*"))
      (keyword-table (symbol "*~A-keyword-hash-table*"))
      (keyword-file mode-name)
      (syntax-table (symbol "*~A-mode-syntax-table*"))
      (key-map (symbol "*~A-key-map*")))
      (eval `(progn 
        ; スペシャル変数の定義
        (defvar ,mode-hook nil)
        
        ,(when key `(defvar ,key-map ',key))
        ,(when keyword `(defvar ,keyword-table nil))
        ,(when syntax `(defvar ,syntax-table ,syntax))
        ; モード関数の作成
        (defun ,mode ()
          (interactive)
          
          ; ローカル変数の削除
          (kill-all-local-variables)
        
          ; 名前二つほど設定
          (setq buffer-mode ',mode)
          (setq mode-name ,mode-name)
          
          ; キーワードの読み込み処理
          ,(if keyword `(progn
            (make-local-variable 'keyword-hash-table)
            (setq keyword-hash-table
              (setq ,keyword-table (or ,keyword-table
                (load-keyword-file ,keyword-file nil))))))
          
          ; シンタックステーブルの適用
          ,(if syntax `(use-syntax-table ,syntax-table))
          
          ; キーマップの適用
          ,(if key `(use-keymap ,key-map))
          
          ; フックを走らせる
          (run-hooks ',mode-hook))))
      
      ; モードを拡張子と対応付ける
      (when ext
        (push (cons ext mode) *auto-mode-alist*)))))
