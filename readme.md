
# Table of Contents

1.  [What's New?](#org94fbf4c)
    1.  [2022-04-10 was released](#orge657986)
    2.  [2021-04-30 was released](#orgffcfdcc)
    3.  [2020-08-26 was released](#org6a44f24)
    4.  [2019-09-18 was released](#org151fce4)
    5.  [2019-05-02 was released](#orge99870e)
    6.  [2018-06-01 was released](#org8e2ecc5)
    7.  [2017-01-07 was released](#org4b7a933)
    8.  [2016-10-23 was released](#org823312f)
2.  [できること](#org9c3eb3d)
3.  [ビルドされるEmacsバイナリ](#orgde8e4a4)
4.  [動作環境](#orgab66eee)
5.  [準備](#org02b3e5b)
6.  [Step-1](#orgc24eb2b)
    1.  [オプション](#orgdd5e10b)
    2.  [Cygwin またはその他のbashシェルからのインストール](#orgd86088d)
    3.  [PowerShell からインストール](#orgf3367fb)
    4.  [自前でダウンロード＆インストール](#org5c236ce)
7.  [Step-2](#orge0200e0)
    1.  [オプション](#org01aa87f)
    2.  [実行](#org9b2b5b8)
8.  [参考文献](#org803ff75)



<a id="org94fbf4c"></a>

# What's New?


<a id="orge657986"></a>

## 2022-04-10 was released

-   Emacs 28.1 ビルド確認
-   ビルドに必要なツールチェインのファイルパスを更新


<a id="orgffcfdcc"></a>

## 2021-04-30 was released

-   Emacs 27.2 ビルド確認
-   ビルドに必要なツールチェインのファイルパスを更新


<a id="org6a44f24"></a>

## 2020-08-26 was released

-   Emacs 27.1 ビルド確認
-   ソース取得のデフォルトをgithubに変更
-   ビルドに必要なツールチェインのファイルパスを更新
-   その他必要な微修正


<a id="org151fce4"></a>

## 2019-09-18 was released

-   Emacs 26.3 ビルド確認
-   ビルドに必要なツールチェインのファイルパスを更新


<a id="orge99870e"></a>

## 2019-05-02 was released

-   Emacs 26.2 ビルド確認
-   start.sh の標準出力を処理と同時に表示するように修正
-   ビルドに必要なツールチェインのファイルパスを更新


<a id="org8e2ecc5"></a>

## 2018-06-01 was released

-   Emacs 26.1 ビルド確認
-   IMEパッチ対応(26.1 rc1)
-   ビルドに必要なツールチェインのファイルパスを更新


<a id="org4b7a933"></a>

## 2017-01-07 was released

-   emacsリポジトリからのビルド対応
-   ビルドに必要なツールチェインのファイルパスを更新


<a id="org823312f"></a>

## 2016-10-23 was released

-   初回リリース


<a id="org9c3eb3d"></a>

# できること

以下を一括して行います  

-   Step-1  
    -   MSYS2ダウンロード
    -   MSYS2アーカイブ展開
    -   MSYS2インストール
-   Step-2  
    -   MSYS2パッケージアップデート
    -   Emacsソース取得  
        -   Emacsアーカイブ(default)  
            -   Emacsアーカイブ：ダウンロード
            -   Emacsアーカイブ：展開
        -   Emacsレポジトリ  
            -   Emacsレポジトリ：クローン
            -   Emacsレポジトリ：チェックアウト
    -   IMEパッチダウンロード
    -   Emacsパッチ適用
    -   Emacsビルド
    -   Emacs依存DLL解析
    -   Emacsポータブル出力


<a id="orgde8e4a4"></a>

# ビルドされるEmacsバイナリ

デフォルトはMinGW64 が起動し x86\_64 で生成される  
MinGW32 で起動すると x86 で生成される  


<a id="orgab66eee"></a>

# 動作環境

↓でテスト  
Windows 10/7 x86\_64  
Cygwin x86\_64 2.1.0(0.287/5/3) 2015-07-14 21:28  


<a id="org02b3e5b"></a>

# 準備

    $ git clone https://github.com/yaruopooner/emacs-build-shells.git

またはzipをダウンロードして展開  


<a id="orgc24eb2b"></a>

# Step-1

MSYS2導入  
すでに導入済みの場合は `Step-2` へ  
ただしパッケージが更新されるので自分のMSYS2環境が更新される可能性がある  
これを避けたい場合は `Step-1` から行う  

以下の手順を行うと自動でMSYS2をダウンロード・展開・起動される  
Cygwin か PowerShell どちらからでもインストール可能  
MSYS2はポータブル版を使用しているので環境を汚さない  

デフォルトでは MinGW64 が起動する  
MinGW32 を起動させるには下記のオプションで設定可能  


<a id="orgdd5e10b"></a>

## オプション

`install-msys2.XXX.options` の記述を編集することにより  
ダウンロードするアーカイブ、起動する MinGW64/32 の設定が可能。  
`install-msys2.XXX.options` が存在しない場合デフォルト値が使用される  


<a id="orgd86088d"></a>

## Cygwin またはその他のbashシェルからのインストール

    $ cd emacs-build-shells
    $ ./install-msys2.sh


<a id="orgf3367fb"></a>

## PowerShell からインストール

実行には `PowerShell 5` の環境が必要。(Windows10は最初から5だった気が)  
5未満の場合は以下からダウンロードしてインストール  
`PowerShell 5.0(Windows Management Framework 5.0)`  
<https://www.microsoft.com/en-us/download/details.aspx?id=50395>  

    cd emacs-build-shells
    install-msys2.ps1

または  
エクスプローラーから `install-msys2.ps1` を実行する  


<a id="org5c236ce"></a>

## 自前でダウンロード＆インストール

<http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/>  
から自前でダウンロードして展開  
`build-shells`  
を  
`/msys64/tmp/`  
へコピーして完了  


<a id="orge0200e0"></a>

# Step-2

MSYS2パッケージアップデートとEmacsビルド  

以下の手順を行うと  
MSYS2アップデートとEmacsアーカイブ/IMEパッチのダウンロード・展開・パッチ適用・ビルドを行う  
`emacs/bin/*.exe` の実行に必要なDLLの依存解析を行い、必要なDLLがコピーされる  

設定変更を行うことによりEmacsアーカイブの代わりにEmacsレポジトリのクローン・チェックアウトに切り替え可能  
※Emacsのレポジトリは大容量のためclone完了までかなりの時間がかかる  


<a id="org01aa87f"></a>

## オプション

`setup-msys2.options` の記述を編集することにより  
インストールするパッケージの追加設定が可能  

`build-emacs.options` の記述を編集することにより  
ダウンロードするアーカイブ、レポジトリ、ブランチ名、パッチ、CFLAGS、configure、DLLなどの追加設定が可能  

`setup-msys2.options` `build-emacs.options` が存在しない場合デフォルト値が使用される  

プロキシ経由している場合は `start.sh` 実行前にシェル上で↓を行ってから実行  

    $ export http_proxy="url:port"
    $ export https_proxy="url:port"

※ `start.options` に記述でもOK  


<a id="org9b2b5b8"></a>

## 実行

`install-msys2` で起動された MinGW64/32 上で作業ディレクトリへ移動し `start.sh` を実行  

パッケージやビルド構成を変更する場合は `start.sh` 実行前に  
`/tmp/build-shells/setup-msys2.options`  
`/tmp/build-shells/build-emacs.options`  
を編集する必要がある  
ビルドを実行してしまった場合は、編集後に再実行でOK  

    $ cd /tmp/build-shells
    $ ./start.sh

実行時にログが表示される  
※ログはファイルとして残る  

msys2のアップデート時にshellの再起動を促される場合がある。  
この場合はmsys2を終了させ `install-msys2.sh` を再実行し、  
起動したmsys2上で再び `start.sh` を実行すればよい。  

ビルドされたEmacsは↓に置かれるので `emacs-XX.X` ごと自分の環境へ移動して利用  
`/msys64/tmp/build-shells/build/XX/emacs-XX.X`  


<a id="org803ff75"></a>

# 参考文献

<http://cha.la.coocan.jp/doc/NTEmacsBuild252.html#sec-7-2>  
<https://github.com/chuntaro/NTEmacs64>  
<https://gist.github.com/rzl24ozi>  

