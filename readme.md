<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. What's New?</a>
<ul>
<li><a href="#sec-1-1">1.1. 2018-06-01 was released</a></li>
<li><a href="#sec-1-2">1.2. 2017-01-07 was released</a></li>
<li><a href="#sec-1-3">1.3. 2016-10-23 was released</a></li>
</ul>
</li>
<li><a href="#sec-2">2. できること</a></li>
<li><a href="#sec-3">3. ビルドされるEmacsバイナリ</a></li>
<li><a href="#sec-4">4. 動作環境</a></li>
<li><a href="#sec-5">5. 準備</a></li>
<li><a href="#sec-6">6. Step-1</a>
<ul>
<li><a href="#sec-6-1">6.1. オプション</a></li>
<li><a href="#sec-6-2">6.2. Cygwin またはその他のbashシェルからのインストール</a></li>
<li><a href="#sec-6-3">6.3. PowerShell からインストール</a></li>
<li><a href="#sec-6-4">6.4. 自前でダウンロード＆インストール</a></li>
</ul>
</li>
<li><a href="#sec-7">7. Step-2</a>
<ul>
<li><a href="#sec-7-1">7.1. オプション</a></li>
<li><a href="#sec-7-2">7.2. 実行</a></li>
</ul>
</li>
<li><a href="#sec-8">8. 参考文献</a></li>
</ul>
</div>
</div>



# What's New?<a id="sec-1" name="sec-1"></a>

## 2018-06-01 was released<a id="sec-1-1" name="sec-1-1"></a>

-   Emacs 26.1 ビルド確認
-   IMEパッチ対応(26.1 rc1)

## 2017-01-07 was released<a id="sec-1-2" name="sec-1-2"></a>

-   emacsリポジトリからのビルド対応

## 2016-10-23 was released<a id="sec-1-3" name="sec-1-3"></a>

-   初回リリース

# できること<a id="sec-2" name="sec-2"></a>

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

# ビルドされるEmacsバイナリ<a id="sec-3" name="sec-3"></a>

デフォルトはMinGW64 が起動し x86\_64 で生成される  
MinGW32 で起動すると x86 で生成される  

# 動作環境<a id="sec-4" name="sec-4"></a>

↓でテスト  
Windows 10/7 x86\_64  
Cygwin x86\_64 2.1.0(0.287/5/3) 2015-07-14 21:28  

# 準備<a id="sec-5" name="sec-5"></a>

    $ git clone https://github.com/yaruopooner/emacs-build-shells.git

またはzipをダウンロードして展開  

# Step-1<a id="sec-6" name="sec-6"></a>

MSYS2導入  
すでに導入済みの場合は `Step-2` へ  
ただしパッケージが更新されるので自分のMSYS2環境が更新される可能性がある  
これを避けたい場合は `Step-1` から行う  

以下の手順を行うと自動でMSYS2をダウンロード・展開・起動される  
Cygwin か PowerShell どちらからでもインストール可能  
MSYS2はポータブル版を使用しているので環境を汚さない  

デフォルトでは MinGW64 が起動する  
MinGW32 を起動させるには下記のオプションで設定可能  

## オプション<a id="sec-6-1" name="sec-6-1"></a>

`install-msys2.XXX.options` の記述を編集することにより  
ダウンロードするアーカイブ、起動する MinGW64/32 の設定が可能。  
`install-msys2.XXX.options` が存在しない場合デフォルト値が使用される  

## Cygwin またはその他のbashシェルからのインストール<a id="sec-6-2" name="sec-6-2"></a>

    $ cd emacs-build-shells
    $ ./install-msys2.sh

## PowerShell からインストール<a id="sec-6-3" name="sec-6-3"></a>

実行には `PowerShell 5` の環境が必要。(Windows10は最初から5だった気が)  
5未満の場合は以下からダウンロードしてインストール  
`PowerShell 5.0(Windows Management Framework 5.0)`  
<https://www.microsoft.com/en-us/download/details.aspx?id=50395>  

    cd emacs-build-shells
    install-msys2.ps1

または  
エクスプローラーから `install-msys2.ps1` を実行する  

## 自前でダウンロード＆インストール<a id="sec-6-4" name="sec-6-4"></a>

<http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/>  
から自前でダウンロードして展開  
`build-shells`  
を  
`/msys64/tmp/`  
へコピーして完了  

# Step-2<a id="sec-7" name="sec-7"></a>

MSYS2パッケージアップデートとEmacsビルド  

以下の手順を行うと  
MSYS2アップデートとEmacsアーカイブ/IMEパッチのダウンロード・展開・パッチ適用・ビルドを行う  
`emacs/bin/*.exe` の実行に必要なDLLの依存解析を行い、必要なDLLがコピーされる  

設定変更を行うことによりEmacsアーカイブの代わりにEmacsレポジトリのクローン・チェックアウトに切り替え可能  
※Emacsのレポジトリは大容量のためclone完了までかなりの時間がかかる  

## オプション<a id="sec-7-1" name="sec-7-1"></a>

`setup-msys2.options` の記述を編集することにより  
インストールするパッケージの追加設定が可能  

`build-emacs.options` の記述を編集することにより  
ダウンロードするアーカイブ、レポジトリ、ブランチ名、パッチ、CFLAGS、configure、DLLなどの追加設定が可能  

`setup-msys2.options` `build-emacs.options` が存在しない場合デフォルト値が使用される  

プロキシ経由している場合は `start.sh` 実行前にシェル上で↓を行ってから実行  

    $ export http_proxy="url:port"
    $ export https_proxy="url:port"

※ `start.options` に記述でもOK  

## 実行<a id="sec-7-2" name="sec-7-2"></a>

`install-msys2` で起動された MinGW64/32 上で作業ディレクトリへ移動し `start.sh` を実行  

パッケージやビルド構成を変更する場合は `start.sh` 実行前に  
`/tmp/build-shells/setup-msys2.options`  
`/tmp/build-shells/build-emacs.options`  
を編集する必要がある  
ビルドを実行してしまった場合は、編集後に再実行でOK  

    $ cd /tmp/build-shells
    $ ./start.sh

完了後にログが表示される  
※ログファイルとして残る  

msys2のアップデート時にshellの再起動を促される場合がある。  
この場合はmsys2を終了させ `install-msys2.sh` を再実行し、  
起動したmsys2上で再び `start.sh` を実行すればよい。  

ビルドされたEmacsは↓に置かれるので `emacs-XX.X` ごと自分の環境へ移動して利用  
`/msys64/tmp/build-shells/build/XX/emacs-XX.X`  

# 参考文献<a id="sec-8" name="sec-8"></a>

<http://cha.la.coocan.jp/doc/NTEmacsBuild252.html#sec-7-2>  
<https://github.com/chuntaro/NTEmacs64>  
<https://gist.github.com/rzl24ozi>
