# ResizeImage

ResizeImageは画像ファイルをアスペクト比を変更することなく長辺を指定サイズ以下に縮小するツールです。

# Features

- 単一または複数の画像ファイルを一括して長辺を指定サイズ以下に縮小します。
- 作成したショートカットにドラッグアンドドロップすると、任意の保存先にファイルを保存します。
- jpg, png, gif形式に対応し、そのままの形式で一括で縮小します。
- 長辺が指定サイズより大きい画像ファイルがない場合は出力先フォルダにそのままコピーします。

# Requirement

* Windows10, 11
* PowerShell 5.1

1. resizeimage(ディレクトリごと)を任意の場所に保存
2. resizeimage.ps1のショートカットを任意の場所に作成
3. ショートカットのリンク先の最初に"powershell -ExecutionPolicy RemoteSigned -File "を先頭に追記
    例）powershell -ExecutionPolicy RemoteSigned -File C:\Users\(ユーザー名)\Desktop\resizeimage\resizeimage.ps1

# Usage

1. 画像ファイルをショートカットにドラッグアンドドロップ
2. ダイアログで保存先を指定

# Note

ファイル名に[ (半角スペース), $, ? ", ', (, ), |, %, ., +, =, !, `, <, >, &, {, }, @]が含まれているものは変換できません。

# Author
naoki@bytedesign

# License

"resizeimage" is under [MIT license](https://en.wikipedia.org/wiki/MIT_License).
