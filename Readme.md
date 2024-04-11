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

### 2.Google Drive APIを導入
～～試してやってくれ～～  
https://console.cloud.google.com/    
↓client_idとclient_secretを取って  

### 3.rcloneの設定  
```
rclone config
```
で色々設定
ここもやりながら書いて  

### 4.ファイルの配置
/etc/systemd/system/  
にserviceファイルを配置  

/usr/bin/  
にshファイルを配置  

### 5.ファイルの起動  
```
systemctl start auto_git_tool.service  
```

を入力し、何も出なかったら  

```
systemctl status auto_git_tool.service  
```

で大丈夫そうか確認  
大丈夫そうだったら  

```
systemctl enable auto_git_tool.service  
```

で自動起動の有効化  
終わったら一度閉じ、PowerShellで  

```
wsl --shutdown  
```

を入力、再度起動

```
systemctl status auto_git_tool.service  
```

で再度確認し、大丈夫そうだったら終わり