2ch_jimaku
==========

2ch互換掲示板用の字幕表示ソフト

【実行環境】
Adobe Air 14.0

【説明】
ロジック系はcoffeeフォルダ内を参照
main.coffeeでクリックイベント等を受け取り各modelとviewを操作
コンパイルしたファイルはjs/scripts.js

【未解決不具合】
字幕用のnativeWindowをclose()した時に例外を吐く