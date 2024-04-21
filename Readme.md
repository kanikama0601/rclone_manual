# rcloneのセットアップ用ツール
前にGit向けに作ってたやつの派生品です ↓前の  
https://github.com/kanikama0601/auto_git_tool_shell  

## 事前準備
### 1.rcloneを導入
```
wget https://rclone.org/install.sh && sudo bash install.sh
```
パスワードの入力が必要です(root除く)  
また、時間がかかるかもしれませんが、ちゃんとインストールは進んでるのでご心配なく  
```
rclone version
```
で出たらOK  
<br>

### 2.Google Drive APIを導入
～～試してやってくれ～～  
https://console.cloud.google.com/    
↓client_idとclient_secretを取って  
<br>

### 3.rcloneの設定  
```
rclone config
```
で色々設定  
ここもやりながら書いて  
<br>

### 4.ファイルの作成
`レポジトリのディレクトリ/.github/workflows/～～～～.yml`  
を作成する。ファイル名はわかりやすいやつで。  
今回はファイル名に「google-drive-sync.yml」を使用する。  
<br>

### 5.ワークフローの定義
先程作成したワークフロー内に以下のコードを記述する  
```
name: Sync to Google Drive

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  rclone:
    runs-on: ubuntu-latest
    permissions:
      actions: read
      id-token: write
      contents: read
    steps:
    - name: Checkout repository
      uses: actions/checkout@v2
      with:
        persist-credentials: false
        ssh-key: ${{ secrets.MY_SSH_KEY }}
        repository: ユーザー名/レポジトリ名

    - name: using rclone
      uses: wei/rclone@master
      env:
        RCLONE_CONF: ${{ secrets.RCLONE_CONF }}
      with:
        args: sync . rclone設定名:GDriveのフォルダ --verbose
```
ここで、ユーザー名、レポジトリ名、rclone設定名、GDriveのフォルダを変更する。  
rclone設定名は、先ほど 3.rcloneの設定 で設定したものを使う。　　
GDriveのフォルダ は、先に作成しておくこと。  
作成したファイルは後ほどpushした際に自動的に同期されるのでご心配なく。  
<br>

### 6.Secretの設定
該当するレポジトリを開き、  
`Settings→Secrets and variables→Actions`  
を開く  

まず、New repository secretを押し、Nameを`MY_SSH_KEY`にする。
Secretは普段使うSSH鍵(.pubじゃない方)  
```
-----BEGIN OPENSSH PRIVATE KEY-----
～
～
-----END OPENSSH PRIVATE KEY-----
```
これをコピーする。上下の----の部分も忘れずに。  

作ってない場合や、Actions用に別のキーを用意する場合は、  
(https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)  
こちらのページを参照。  

作成が完了したら、もう一つsecretを作成する。
まず、New repository secretを押し、Nameを`RCLONE_CONF`にする。  
Secretは 3.rcloneの設定 で生成したファイルをコピペする。
デフォルトでは、  
`~/.config/rclone/rclone.conf`  
に生成される。
こちらをcatとかvimとかnanoで開き、丸ごとコピーする。  
複数の関数を定義している場合は、
```
[先程作成した名前]
type = drive
client_id = *************
～
～
team_drive =
```
までをコピペする。  
<br>

### 7.pushする
ここまで出来たら、レポジトリのディレクトリへ行き、
```
git add .
git commit -m "コメント"
git push
```
でpushする。  
この際、エラーが出たら俺に問い合わせる。  
<br>

Google Driveのフォルダにファイルがpushされていたら完了  
<br>

一応例として、resourceにファイルを添付しておく。  
コピペでは使えないので、ちょこちょこ弄ってから使うこと。  
<br>
<br>

一応、遭遇したエラーの対策を記述しておく。  
### <pushの時にユーザー名、パスワードを聞かれる>
actions/checkoutが実行された際、レポジトリのURLをSSHで指定すると回避可能。  
今回、ファイル内で  
`ssh-key: ${{ secrets.MY_SSH_KEY }}`  
と指定している為、起こる確率は低いと思われる。  
<br>

### <pushし、次にpushする際にエラーが出る>
actions/checkoutにrepo/.git/configへの書き込みをさせていることが原因。  
```
git config --list
```
で`$RUNNER_TEMP`とか表示があると、これに該当する。  
基本的には、actions/checkout@v1にするか、
```
uses: actions/checkout@v2
      with:
        persist-credentials: false
```
このように記述することで解消する。  
checkout@v1は`ssh-key`が使えないので、こちらを推奨。  
こちらも記述済みの為、起こる確率は低いと思われる。  
<br>

<Actionsで実行した際にエラーが出る>
起動後、即エラーは大体記述ミス。  
`the 'uses' attribute must be a path, a Docker image, or owner/repo@ref`  
このエラーが出たときは大体HTMLでレポジトリにアクセスしようとした際に発生する。  
自分の場合、actions/checkout@v1を使用しようとした際にエラーが出た。  
後は、レポジトリ名のミスが多い。

rcloneでミスが発生した際は、`RCLONE_CONF`をちゃんと設定したか、GDriveに該当フォルダがあるか、rclone設定名が正しいか、
```
rclone config
```
でconfigを作成したかチェックしよう。  

Checkout Repositoryでエラーが出た際、  
`Could not read from remote repository.`このエラーだと、大体レポジトリ名間違いか、SSH鍵の打ち間違い。  
SSH鍵は、ちゃんと.pubの方をアカウントに連結しているのか確認しよう。  
<br>

### <push/commitの際にHEAD～～とエラーが出る>
原因は、Workflowファイルの不良や、configファイル不良によるエラーで、レポジトリURLがゴチャゴチャになることで発生する。  
基本的にはフォルダごと削除し、再度pullすることが一番早く解決できる。  
push漏れがあれば、バックアップを忘れずに。  