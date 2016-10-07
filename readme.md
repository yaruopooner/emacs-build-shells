<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. 動作環境</a></li>
<li><a href="#sec-2">2. 準備</a></li>
<li><a href="#sec-3">3. 手順１：MSYS2導入</a>
<ul>
<li><a href="#sec-3-1">3.1. Cygwin からインストール</a></li>
<li><a href="#sec-3-2">3.2. PowerShell からインストール</a></li>
<li><a href="#sec-3-3">3.3. 自前でダウンロード＆インストール</a></li>
<li><a href="#sec-3-4">3.4. オプション</a></li>
</ul>
</li>
<li><a href="#sec-4">4. 手順２：MSYS2パッケージアップデートとEmacsビルド</a>
<ul>
<li><a href="#sec-4-1">4.1. オプション</a></li>
</ul>
</li>
<li><a href="#sec-5">5. 参考文献</a></li>
</ul>
</div>
</div>



# 動作環境<a id="sec-1" name="sec-1"></a>

↓でテスト  
Windows 10/7 x86\_64  
Cygwin x86\_64 2.1.0(0.287/5/3) 2015-07-14 21:28  

# 準備<a id="sec-2" name="sec-2"></a>

    git clone https://github.com/yaruopooner/emacs-build-shells.git

またはzipをダウンロードして展開  

# 手順１：MSYS2導入<a id="sec-3" name="sec-3"></a>

すでに導入済みの場合は手順２へ。  
ただしパッケージが更新されるので自分のMSYS2環境が更新される可能性がある  
これを避けたい場合は手順１から行う  

以下の手順を行うと自動でMSYS2をダウンロード・展開・起動される  
Cygwin か PowerShell どちらからでもインストール可能  
MSYS2はポータブル版を使用しているので環境を汚していないはず  

## Cygwin からインストール<a id="sec-3-1" name="sec-3-1"></a>

    cd emacs-build-shells
    ./install-msys2.sh

## PowerShell からインストール<a id="sec-3-2" name="sec-3-2"></a>

実行にはPowerShell 5の環境が必要。(Windows10は最初から5だった気が)  
5未満の場合は以下からダウンロードしてインストール  
PowerShell 5.0(Windows Management Framework 5.0)  
<https://www.microsoft.com/en-us/download/details.aspx?id=50395>  

    cd emacs-build-shells
    install-msys2.ps1

または  
エクスプローラーからinstall-msys2.ps1を実行する  

## 自前でダウンロード＆インストール<a id="sec-3-3" name="sec-3-3"></a>

<http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/>  
から自前でダウンロードして展開  
build-shells  
を  
*msys64/tmp*  
へコピーして完了  

## オプション<a id="sec-3-4" name="sec-3-4"></a>

install-msys2.XXX.options の記述を編集することにより  
ダウンロードするアーカイブ、起動する MinGW64/32 の設定が可能。  
install-msys2.XXX.options が存在しない場合デフォルト値が使用される  

# 手順２：MSYS2パッケージアップデートとEmacsビルド<a id="sec-4" name="sec-4"></a>

以下の手順を行うと自動でMSYS2アップデートとEmacsアーカイブのダウンロード・展開・ビルドを行う。  
emacs/bin/\*.exe の実行に必要なDLLの依存解析を行い、必要なDLLがコピーされる。  

※プロキシ経由を行っている場合は start.sh 実行前にシェル上で↓を行ってから実行、もしくは以下の設定を build-emacs.options に記述する  

    $ export http_proxy="url:port"
    $ export https_proxy="url:port"

install-msys2 で起動された MinGW64/32 上で作業ディレクトリへ移動して start.sh を実行  

    cd /tmp/build-shells
    ./start.sh

完了後にログが表示される。  
※ログファイルとして残る。  

ビルドされたEmacsは↓に置かれるので emacs-XX.X ごと自分の環境へ移動して利用。  
/msys64/tmp/build-shells/build/XX/emacs-XX.X  

## オプション<a id="sec-4-1" name="sec-4-1"></a>

build-emacs.options の記述を編集することにより  
ダウンロードするアーカイブ、パッチ、 configureの追加設定が可能。  
build-emacs.options が存在しない場合デフォルト値が使用される。  

# 参考文献<a id="sec-5" name="sec-5"></a>

<http://cha.la.coocan.jp/doc/NTEmacsBuild251.html#sec-7-2>  
<https://github.com/chuntaro/NTEmacs64>  
<https://gist.github.com/rzl24ozi/8c20b904c9f5e588ba99>
