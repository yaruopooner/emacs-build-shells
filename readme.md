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
<li><a href="#sec-3-3">3.3. オプション</a></li>
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

↓でテストしました  
Windows 10/7 x86\_64  
Cygwin x86\_64 2.1.0(0.287/5/3) 2015-07-14 21:28  

# 準備<a id="sec-2" name="sec-2"></a>

    git clone https://github.com/yaruopooner/emacs-build-shells.git

またはzipをダウンロードして展開  

# 手順１：MSYS2導入<a id="sec-3" name="sec-3"></a>

以下の手順を行うと自動でMSYS2をダウンロード・展開・起動します  
Cygwin か PowerShell どちらからでもインストール可能  
MSYS2はポータブル版を使用しているので環境を汚していないはず。  

## Cygwin からインストール<a id="sec-3-1" name="sec-3-1"></a>

    cd emacs-build-shells
    ./install-msys2.sh

## PowerShell からインストール<a id="sec-3-2" name="sec-3-2"></a>

実行にはPowerShell 5の環境が必要です。(Windows10は最初から5だった気が)  
5未満の場合は以下からダウンロードしてインストール  
PowerShell 5.0(Windows Management Framework 5.0)  
<https://www.microsoft.com/en-us/download/details.aspx?id=50395>  

    cd emacs-build-shells
    install-msys2.ps1

または  
エクスプローラーからinstall-msys2.ps1を実行する  

## オプション<a id="sec-3-3" name="sec-3-3"></a>

install-msys2.options の記述を編集することにより  
ダウンロードするアーカイブ、起動する MinGW64/32 の設定が可能です。  
install-msys2.options が存在しない場合デフォルト値が使用されます。  

# 手順２：MSYS2パッケージアップデートとEmacsビルド<a id="sec-4" name="sec-4"></a>

以下の手順を行うと自動でMSYS2アップデートとEmacsアーカイブのダウンロード・展開・ビルドを行います。  
Emacsの実行に必要なDLLの依存解析を行い、必要なDLLがコピーされます。  

※プロキシ経由を行っている場合は start.sh 実行前にシェル上で↓を行ってから実行、もしくは以下の設定を build-emacs.options に記述  

    $ export http_proxy="url:port"
    $ export https_proxy="url:port"

install-msys2 で起動された MinGW64/32 上で作業ディレクトリへ移動して start.sh を実行  

    cd /tmp/build-shells
    ./start.sh

完了後にログが表示されます。  
※ファイルとして残っています。  

ビルドされたEmacsは↓に置かれるので emacs-XX.X ごと自分の環境へ移動して利用します。  
/msys64/tmp/build-shells/build/XX/emacs-XX.X  

## オプション<a id="sec-4-1" name="sec-4-1"></a>

build-emacs.options の記述を編集することにより  
ダウンロードするアーカイブ、パッチ、 configureの追加設定が可能です。  
build-emacs.options が存在しない場合デフォルト値が使用されます。  

# 参考文献<a id="sec-5" name="sec-5"></a>

<https://github.com/chuntaro/NTEmacs64>  
<http://cha.la.coocan.jp/doc/NTEmacsBuild251.html#sec-7-2>
