<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. できること</a></li>
<li><a href="#sec-2">2. 動作環境</a></li>
<li><a href="#sec-3">3. 準備</a></li>
<li><a href="#sec-4">4. Step-1</a>
<ul>
<li><a href="#sec-4-1">4.1. ビルドされるバイナリ</a></li>
<li><a href="#sec-4-2">4.2. オプション</a></li>
<li><a href="#sec-4-3">4.3. Cygwin またはその他のシェルからのインストール</a></li>
<li><a href="#sec-4-4">4.4. PowerShell からインストール</a></li>
<li><a href="#sec-4-5">4.5. 自前でダウンロード＆インストール</a></li>
</ul>
</li>
<li><a href="#sec-5">5. Step-2</a>
<ul>
<li><a href="#sec-5-1">5.1. オプション</a></li>
</ul>
</li>
<li><a href="#sec-6">6. 参考文献</a></li>
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

# 動作環境<a id="sec-2" name="sec-2"></a>

↓でテスト  
Windows 10/7 x86\_64  
Cygwin x86\_64 2.1.0(0.287/5/3) 2015-07-14 21:28  

# 準備<a id="sec-3" name="sec-3"></a>

    $ git clone https://github.com/yaruopooner/emacs-build-shells.git

またはzipをダウンロードして展開  

# Step-1<a id="sec-4" name="sec-4"></a>

MSYS2導入  
すでに導入済みの場合は `Step-2` へ  
ただしパッケージが更新されるので自分のMSYS2環境が更新される可能性がある  
これを避けたい場合は `Step-1` から行う  

以下の手順を行うと自動でMSYS2をダウンロード・展開・起動される  
Cygwin か PowerShell どちらからでもインストール可能  
MSYS2はポータブル版を使用しているので環境を汚さない  

デフォルトでは MinGW64 が起動する  
MinGW32 を起動させるには下記のオプションで設定可能  

## ビルドされるバイナリ<a id="sec-4-1" name="sec-4-1"></a>

デフォルトは x86\_64 が生成される  
MinGW32 で起動すると x86 が生成される  

## オプション<a id="sec-4-2" name="sec-4-2"></a>

`install-msys2.XXX.options` の記述を編集することにより  
ダウンロードするアーカイブ、起動する MinGW64/32 の設定が可能。  
`install-msys2.XXX.options` が存在しない場合デフォルト値が使用される  

## Cygwin またはその他のシェルからのインストール<a id="sec-4-3" name="sec-4-3"></a>

    $ cd emacs-build-shells
    $ ./install-msys2.sh

## PowerShell からインストール<a id="sec-4-4" name="sec-4-4"></a>

実行には `PowerShell 5` の環境が必要。(Windows10は最初から5だった気が)  
5未満の場合は以下からダウンロードしてインストール  
`PowerShell 5.0(Windows Management Framework 5.0)`  
<https://www.microsoft.com/en-us/download/details.aspx?id=50395>  

    cd emacs-build-shells
    install-msys2.ps1

または  
エクスプローラーから `install-msys2.ps1` を実行する  

## 自前でダウンロード＆インストール<a id="sec-4-5" name="sec-4-5"></a>

<http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/>  
から自前でダウンロードして展開  
`build-shells`  
を  
`/msys64/tmp/`  
へコピーして完了  

# Step-2<a id="sec-5" name="sec-5"></a>

MSYS2パッケージアップデートとEmacsビルド  

以下の手順を行うと自動でMSYS2アップデートとEmacsアーカイブ＆IMEパッチのダウンロード・展開・パッチ適用・ビルドを行う  
`emacs/bin/*.exe` の実行に必要なDLLの依存解析を行い、必要なDLLがコピーされる  

※プロキシ経由を行っている場合は `start.sh` 実行前にシェル上で↓を行ってから実行  

    $ export http_proxy="url:port"
    $ export https_proxy="url:port"

`install-msys2` で起動された MinGW64/32 上で作業ディレクトリへ移動して start.sh を実行  

    $ cd /tmp/build-shells
    $ ./start.sh

完了後にログが表示される。  
※ログファイルとして残る。  

ビルドされたEmacsは↓に置かれるので `emacs-XX.X` ごと自分の環境へ移動して利用。  
`/msys64/tmp/build-shells/build/XX/emacs-XX.X`  

## オプション<a id="sec-5-1" name="sec-5-1"></a>

`build-emacs.options` の記述を編集することにより  
ダウンロードするアーカイブ、パッチ、CFLAGS、configureの追加設定が可能。  
`build-emacs.options` が存在しない場合デフォルト値が使用される。  

# 参考文献<a id="sec-6" name="sec-6"></a>

<http://cha.la.coocan.jp/doc/NTEmacsBuild251.html#sec-7-2>  
<https://github.com/chuntaro/NTEmacs64>  
<https://gist.github.com/rzl24ozi/8c20b904c9f5e588ba99>
