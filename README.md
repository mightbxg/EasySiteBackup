# EasySiteBackup
## 个人站点备份工具

---
# 作用
备份服务器上的个人站点的网站目录和数据库（MySQL）

# 功能
1. 自动将网站目录和数据库打包备份起来；
2. 可设置保留的备份数目，自动删除多余的备份，防止服务器空间浪费；
3. 可配合网盘上传脚本（如Dropbox Uploader或者bpcs_uploader）自动将备份上传到网盘；
4. 可配合crontab定时自动备份及上传

# 使用方法
首先要修改配置文件 configure.ini，具体说明如下：
```ini
[mysql]
mysqlPath = /usr/bin    # mysql所在目录，一定要确保该目录下有mysqldump文件
dbName = dbName         # 需备份的数据库名称
dbUser = root           # 数据库用户
dbPwd = dbPwd           # 数据库密码

[site]
sitePath = /www/web/blog_victorbian_rocks   # 需备份的站点目录
siteName = blog_victorbian_rocks            # 站点名称，可任取，仅作为打包文件名

[backup]
maxCopy = 5             # 保留的备份数目，超过该值时将自动删除多余旧版本
pkgName = blog          # 备份文件名称，可任取
dstPath = /home/backup  # 备份文件存放目录

[upload]
uploader = /usr/dropbox_uploader.sh # 网站上传脚本的绝对位置
```
其中 uploader 必须是支持```upload <LOCAL_FILE> <REMOTE_FILE>```命令的网盘上传脚本，比如[Dropbox Uploader][1]（dropbox_uploader.sh）或者[bpcs_uploader][2]（bpcs_uploader.php）。如果不想上传到网盘则不用设置 uploader。

然后将 easySiteBackup.sh 和 configure.ini 上传到服务器同一目录下，并用```chmod +x easySiteBackup.sh```赋予执行权限即可。

配置正确的情况下，执行 easySiteBackup.sh 即可一步到位完成“数据库备份->站点目录打包压缩->整体打包压缩->删除多余备份->上传到网盘”的全过程。配合crontab可以定时执行备份。

**补充说明**：本工具会自动在所在目录下生成 task.log 执行日志，包含一些出错信息。


  [1]: https://github.com/andreafabrizi/Dropbox-Uploader "Dropbox Uploader"
  [2]: https://github.com/oott123/bpcs_uploader "bpcs_uploader"