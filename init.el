;;;;;;;;;;;
;;flymake;;
;;;;;;;;;;;


;; 参考：http://d.hatena.ne.jp/suztomo/20080905/1220633281
(require 'flymake)
(defun flymake-cc-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "g++" (list "-Wall" "-std=c++14" "-Wextra" "-fsyntax-only" local-file))))

(push '("\\.cpp$" flymake-cc-init) flymake-allowed-file-name-masks)
(push '("\\.cc$" flymake-cc-init) flymake-allowed-file-name-masks)

(add-hook 'c++-mode-hook
          '(lambda ()
             (flymake-mode t)))


;;;;;;;;;;;;;;
;;;site-lisp;;
;;;;;;;;;;;;;;

(let ( (default-directory
         (file-name-as-directory (concat user-emacs-directory "site-lisp")))
       )
  (add-to-list 'load-path default-directory)
  (normal-top-level-add-subdirs-to-load-path)
  )

;;;;;;;;;;;;;
;;language;;;
;;;;;;;;;;;;;

;; デフォルトの文字コード
(set-default-coding-systems 'utf-8-unix)

;; テキストファイル／新規バッファの文字コード
(prefer-coding-system 'utf-8-unix)

;; ファイル名の文字コード
(set-file-name-coding-system 'utf-8-unix)

;; キーボード入力の文字コード
(set-keyboard-coding-system 'utf-8-unix)

;; サブプロセスのデフォルト文字コード
(setq default-process-coding-system '(undecided-dos . utf-8-unix))

;; 環境依存文字 文字化け対応
(set-charset-priority 'ascii 'japanese-jisx0208 'latin-jisx0201
                      'katakana-jisx0201 'iso-8859-1 'cp1252 'unicode)
(set-coding-system-priority 'utf-8 'euc-jp 'iso-2022-jp 'cp932)



;;;;;;;;;;
;;font;;;;
;;;;;;;;;;

;; デフォルト フォント
;; (set-face-attribute 'default nil :family "Migu 1M" :height 110)
;;(set-face-font 'default "Migu 1M-12:antialias=standard")

;; プロポーショナル フォント
;; (set-face-attribute 'variable-pitch nil :family "Migu 1M" :height 110)
;;(set-face-font 'variable-pitch "Migu 1M-11:antialias=standard")

;; 等幅フォント
;;(set-face-attribute 'fixed-pitch nil :family "Migu 1M" :height 110)
;;(set-face-font 'fixed-pitch "Migu 1M-11:antialias=standard")

;; ツールチップ表示フォント
;; (set-face-attribute 'tooltip nil :family "Migu 1M" :height 90)
;;(set-face-font 'tooltip "Migu 1M-9:antialias=standard")

(set-face-attribute 'default nil :font "DejaVu Sans Mono 13")
(set-frame-font "DejaVu Sans Mono 13" nil t)


;;;;;;;;;
;;frame;;
;;;;;;;;;

(setq default-frame-alist
      (append '((width                . 84 )  ; フレーム幅
                (height               . 34 ) ; フレーム高
                (left                 . 560 ) ; 配置左位置
                (top                  . 0 ) ; 配置上位置
                (line-spacing         . 0  ) ; 文字間隔
                (left-fringe          . 10 ) ; 左フリンジ幅
                (right-fringe         . 11 ) ; 右フリンジ幅
                (menu-bar-lines       . 1  ) ; メニューバー
                (tool-bar-lines       . 1  ) ; ツールバー
                (vertical-scroll-bars . 1  ) ; スクロールバー
                (scroll-bar-width     . 17 ) ; スクロールバー幅
                (cursor-type          . box) ; カーソル種別
                (alpha                . 100) ; 透明度
                ) default-frame-alist) )
(setq initial-frame-alist default-frame-alist)

;; ツールバーを非表示
(tool-bar-mode -1)
;; メニューバーを非表示
(menu-bar-mode -1)

;;;;;;;;;;
;;cursor;;
;;;;;;;;;;

;; カーソルの点滅（有効：1、無効：0）
(blink-cursor-mode 0)

;; IME無効／有効時のカーソルカラー定義
(unless (facep 'cursor-ime-off)
  (make-face 'cursor-ime-off)
  (set-face-attribute 'cursor-ime-off nil
                      :background "DarkRed" :foreground "White")
  )
(unless (facep 'cursor-ime-on)
  (make-face 'cursor-ime-on)
  (set-face-attribute 'cursor-ime-on nil
                      :background "DarkGreen" :foreground "White")
  )

;; IME無効／有効時のカーソルカラー設定
(advice-add 'ime-force-on
            :before (lambda (&rest args)
                      (if (facep 'cursor-ime-on)
                          (let ( (fg (face-attribute 'cursor-ime-on :foreground))
                                 (bg (face-attribute 'cursor-ime-on :background)) )
                            (set-face-attribute 'cursor nil :foreground fg :background bg) )
                        )
                      ))
(advice-add 'ime-force-off
            :before (lambda (&rest args)
                      (if (facep 'cursor-ime-off)
                          (let ( (fg (face-attribute 'cursor-ime-off :foreground))
                                 (bg (face-attribute 'cursor-ime-off :background)) )
                            (set-face-attribute 'cursor nil :foreground fg :background bg) )
                        )
                      ))

;; 現在行のハイライト
(defface hlline-face
  '((((class color)
      (background dark))
     (:background "dark slate gray"))
    (((class color)
      (background light))
     (:background  "#98FB98"))
    (t
     ()))
  "*Face used by hl-line.")
(setq hl-line-face 'hlline-face)
(global-hl-line-mode)

;;対応する括弧の表示
(show-paren-mode t)

;; 2スペースインデント
(setq-default
 c-basic-offset   2
 tab-width        2
 indent-tabs-mode nil)


;;;;;;;;;
;;linum;;
;;;;;;;;;
(require 'linum)

;; 行移動を契機に描画
(defvar linum-line-number 0)
(declare-function linum-update-current "linum" ())
(defadvice linum-update-current
    (around linum-update-current-around activate compile)
  (unless (= linum-line-number (line-number-at-pos))
    (setq linum-line-number (line-number-at-pos))
    ad-do-it
    ))

;; バッファ中の行番号表示の遅延設定
(defvar linum-delay nil)
(setq linum-delay t)
(defadvice linum-schedule (around linum-schedule-around () activate)
  (run-with-idle-timer 1.0 nil #'linum-update-current))

;; 行番号の書式
(defvar linum-format nil)
(setq linum-format "%5d")

;; バッファ中の行番号表示（有効：t、無効：nil）
(global-linum-mode t)

;; 文字サイズ
(set-face-attribute 'linum nil :height 1.0)


;; 行番号の表示（有効：t、無効：nil）
(line-number-mode t)

;; 列番号の表示（有効：t、無効：nil）
(column-number-mode t)



;;;;;;;;;;
;;tabbar;;
;;;;;;;;;;

(require 'tabbar)

;; tabbar有効化（有効：t、無効：nil）
(call-interactively 'tabbar-mode t)

;; タブ切り替え
(global-set-key (kbd "<C-tab>") 'tabbar-forward-tab)
(global-set-key (kbd "C-q")     'tabbar-backward-tab)



;;;;;;;;;;
;;theme;;;
;;;;;;;;;;

;; テーマ格納ディレクトリのパス追加
(add-to-list 'custom-theme-load-path
             (file-name-as-directory (concat user-emacs-directory "theme"))
             )

(load-theme 'gnupack-dark t);; dark



;;;;;;;;;;;;
;;template;;
;;;;;;;;;;;;

;; temlate(ICPCでは必要なし)
(auto-insert-mode)
(setq auto-insert-directory "~/.emacs.d/insert/")
(define-auto-insert "\\.cpp$" "template.cpp")
(define-auto-insert "\\.cc$" "template.cpp")

;;;;;;;;;;;;
;;command;;
;;;;;;;;;;;;
(global-set-key "\C-z" 'undo)            ;; Undo
(global-set-key "\C-s" 'isearch-forward) ;; 検索
(global-set-key "\C-r" 'query-replace)   ;; 置換
(global-set-key "\C-j" 'dabbrev-expand)  ;; 補完
(global-set-key "\C-h" 'keyboard-quit)   ;; 頻発するヘルプの誤爆を殺す

;;;;;;;;;;;
;;message;;
;;;;;;;;;;;
(setq inhibit-startup-message t)         ;; うざいメッセージを殺す

;;;;;;;;
;;mozc;;
;;;;;;;;
(require 'mozc)
(set-language-environment "Japanese")
(setq default-input-method "japanese-mozc")
