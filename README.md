Windows Setup Scripts
====

## Description

Windowsアプリをchocolateyですぐにインストール/アップデートするためのスクリプト

## Usage

### 1. レポジトリ持ってくる

git clone https://github.com/hijili/windows_setup_scripts.git

もしくはzipでDL

### 2. applist.sample.txt を applist.txt にrename

### 3. 必要なアプリを applist.txtに書く

アプリ名はchocolateyで一意の名前を探そう。

https://chocolatey.org/packages でアプリケーションを検索

日本語の場合、"chocolatey {インストールしたいアプリケーション名}" とかでググって出てくれば多分見つかるかと。chocolateyになければ自分で入れてね。

### 4. スクリプトを実行

GUIなら executor.bat を 右クリック＞管理者権限で実行

CUIなら、管理者権限のpoershellで powershell -NoProfile -ExecutionPolicy Unrestricted .\setup.ps1

### 5. コマンド入力

- init で chocolatey をinstall
- install で applist.txt のアプリケーションを全てinstall
- update で applist.txt のアプリケーションを全てupdate (exclude_update_list.txt に書かれてるものは除外)
- config は非常に個人的な自動セットアップ内容です…　需要あれば分割するけど…

#### configの中身

- CapsとCtlを入れ替える
- デスクトップアイコンの間隔を狭める
- WSLを有効化する

## Requirement

Windows10

## Licence

No Licence
