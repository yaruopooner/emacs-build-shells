<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. できること</a></li>
<li><a href="#sec-2">2. ビルドされるEmacsバイナリ</a></li>
<li><a href="#sec-3">3. 動作環境</a></li>
<li><a href="#sec-4">4. 準備</a></li>
<li><a href="#sec-5">5. Step-1</a>
<ul>
<li><a href="#sec-5-1">5.1. オプション</a></li>
<li><a href="#sec-5-2">5.2. Cygwin またはその他のシェルからのインストール</a></li>
<li><a href="#sec-5-3">5.3. PowerShell からインストール</a></li>
<li><a href="#sec-5-4">5.4. 自前でダウンロード＆インストール</a></li>
</ul>
</li>
<li><a href="#sec-6">6. Step-2</a>
<ul>
<li><a href="#sec-6-1">6.1. オプション</a></li>
<li><a href="#sec-6-2">6.2. 実行</a></li>
</ul>
</li>
<li><a href="#sec-7">7. 参考文献</a></li>
</ul>
</div>
</div>



# できること<a id="sec-1" name="sec-1"></a>

以下を一括して行います  
-   Step-1  
    -   MSYS2ダウンロード
    -   MSYS2アーカイブ展開
    -   MSYS2インストール
-   Step-2  
    -   MSYS2パッケージアップデート
    -   Emacsアーカイブダウンロード
    -   IMEパッチダウンロード
    -   Emacsアーカイブ展開
    -   Emacsパッチ適用
    -   Emacsビルド
    -   Emacs依存DLL解析
    -   Emacsポータブル出力

# ビルドされるEmacsバイナリ<a id="sec-2" name="sec-2"></a>

デフォルトはMinGW64 が起動し x86\_64 で生成される  
MinGW32 で起動すると x86 で生成される  

# 動作環境<a id="sec-3" name="sec-3"></a>

↓でテスト  
Windows 10/7 x86\_64  
Cygwin x86\_64 2.1.0(0.287/5/3) 2015-07-14 21:28  

# 準備<a id="sec-4" name="sec-4"></a>

    $ git clone https://github.com/yaruopooner/emacs-build-shells.git

またはzipをダウンロードして展開  

# Step-1<a id="sec-5" name="sec-5"></a>

MSYS2導入  
すでに導入済みの場合は `Step-2` へ  
ただしパッケージが更新されるので自分のMSYS2環境が更新される可能性がある  
これを避けたい場合は `Step-1` から行う  

以下の手順を行うと自動でMSYS2をダウンロード・展開・起動される  
Cygwin か PowerShell どちらからでもインストール可能  
MSYS2はポータブル版を使用しているので環境を汚さない  

デフォルトでは MinGW64 が起動する  
MinGW32 を起動させるには下記のオプションで設定可能  

## オプション<a id="sec-5-1" name="sec-5-1"></a>

`install-msys2.XXX.options` の記述を編集することにより  
ダウンロードするアーカイブ、起動する MinGW64/32 の設定が可能。  
`install-msys2.XXX.options` が存在しない場合デフォルト値が使用される  

## Cygwin またはその他のシェルからのインストール<a id="sec-5-2" name="sec-5-2"></a>

    $ cd emacs-build-shells
    $ ./install-msys2.sh

## PowerShell からインストール<a id="sec-5-3" name="sec-5-3"></a>

実行には `PowerShell 5` の環境が必要。(Windows10は最初から5だった気が)  
5未満の場合は以下からダウンロードしてインストール  
`PowerShell 5.0(Windows Management Framework 5.0)`  
<https://www.microsoft.com/en-us/download/details.aspx?id=50395>  

    cd emacs-build-shells
    install-msys2.ps1

または  
エクスプローラーから `install-msys2.ps1` を実行する  

## 自前でダウンロード＆インストール<a id="sec-5-4" name="sec-5-4"></a>

<http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/>  
から自前でダウンロードして展開  
`build-shells`  
を  
`/msys64/tmp/`  
へコピーして完了  

# Step-2<a id="sec-6" name="sec-6"></a>

MSYS2パッケージアップデートとEmacsビルド  

以下の手順を行うと  
MSYS2アップデートとEmacsアーカイブ＆IMEパッチのダウンロード・展開・パッチ適用・ビルドを行う  
`emacs/bin/*.exe` の実行に必要なDLLの依存解析を行い、必要なDLLがコピーされる  

## オプション<a id="sec-6-1" name="sec-6-1"></a>

`build-emacs.options` の記述を編集することにより  
ダウンロードするアーカイブ、パッチ、CFLAGS、configure、DLLの追加設定が可能  
`build-emacs.options` が存在しない場合デフォルト値が使用される  

プロキシ経由している場合は `start.sh` 実行前にシェル上で↓を行ってから実行  

    $ export http_proxy="url:port"
    $ export https_proxy="url:port"

## 実行<a id="sec-6-2" name="sec-6-2"></a>

`install-msys2` で起動された MinGW64/32 上で作業ディレクトリへ移動し `start.sh` を実行  

ビルド構成を変更する場合は `start.sh` 実行前に `/tmp/build-shells/build-emacs.options` を編集する必要がある  
ビルドを実行してしまった場合は、編集後に再実行でOK  

    $ cd /tmp/build-shells
    $ ./start.sh

完了後にログが表示される  
※ログファイルとして残る  

ビルドされたEmacsは↓に置かれるので `emacs-XX.X` ごと自分の環境へ移動して利用  
`/msys64/tmp/build-shells/build/XX/emacs-XX.X`  

# 参考文献<a id="sec-7" name="sec-7"></a>

<http://cha.la.coocan.jp/doc/NTEmacsBuild251.html#sec-7-2>  
<https://github.com/chuntaro/NTEmacs64>  
<https://gist.github.com/rzl24ozi/8c20b904c9f5e588ba99>
