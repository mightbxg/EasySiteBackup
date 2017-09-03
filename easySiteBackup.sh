#!/bin/bash
# EasySiteBackup, backup website & mysql
# author victorbian
# url https://blog.victorbian.rocks

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

# read params from confFileiguration file
currentPath=$(cd `dirname $0`; pwd)
confFile=$currentPath/configure.ini
logFile=$currentPath/task.log
if [ ! -f $confFile ]; then
	echo -e "Error: configuration doesn't exist.\n>>> no $confFile"
	echo -e "Error: configuration doesn't exist.\n>>> no $confFile" >> $logFile
	exit 1
fi
mysqlPath=$(readINI $confFile mysql mysqlPath)
dbName=$(readINI $confFile mysql dbName)
dbUser=$(readINI $confFile mysql dbUser)
dbPwd=$(readINI $confFile mysql dbPwd)
sitePath=$(readINI $confFile site sitePath)
siteName=$(readINI $confFile site siteName)
maxCopy=$(readINI $confFile backup maxCopy)
pkgName=$(readINI $confFile backup pkgName)
dstPath=$(readINI $confFile backup dstPath)
uploader=$(readINI $confFile upload uploader)

# initialize backup filenames
[ -d  $dstPath ] || mkdir -p $dstPath
now=$(date +"%Y%m%d%H%M")
fnSqlBu=$dstPath/$dbName\_$now.sql
fnSiteBu=$dstPath/$siteName\_$now.tar.gz
fnPkg=$pkgName\_$now.tar.gz
fnPkgFull=$dstPath/$fnPkg
echo -e "\nTime: $now" >> $logFile

# backup mysql
fnDump=$mysqlPath/mysqldump
if [ ! -f $fnDump ]; then
	echo -e "Error: mysqldump doesn't exist.\n>>> fnDump = $fnDump"
	echo -e "Error: mysqldump doesn't exist.\n>>> fnDump = $fnDump" >> $logFile
	exit 1
fi
# cd $mysqlPath
$mysqlPath/mysqldump -u$dbUser -p$dbPwd $dbName>$fnSqlBu 2>> $logFile
if [ $? != 0 ]; then
	echo "Error: fail to backup $dbName"
	echo "Error: fail to backup $dbName" >> $logFile
	exit 2
fi
echo ">>> $dbName backuped."

# backup website
if [ ! -d $sitePath ]; then
	echo -e "Error: site path doesn't exist.\n>>> sitePath = $sitePath"
	echo -e "Error: site path doesn't exist.\n>>> sitePath = $sitePath" >> $logFile
	exit 3
fi
tar zcf $fnSiteBu $sitePath
echo ">>> $siteName backuped."

# pack and compress
tar zcf $fnPkgFull $fnSiteBu $fnSqlBu
rm -f $fnSiteBu $fnSqlBu
echo ">>> Files packed to $fnPkg."
echo ">>> $fnPkg created." >> $logFile

# remove old packages
_fileLst=`ls -lt $dstPath | awk '{print $9}' | grep "^$pkgName\_[0-9]\{12\}\.tar\.gz$"`
_filecount=0
for _file in $_fileLst
do
	_fileName=$dstPath/$_file
	[ -f $_fileName ] || continue
	let _filecount+=1
	if [ $_filecount -gt $maxCopy ]; then
		rm -f $_fileName
		echo ">>> $_file deleted."
		echo ">>> $_file deleted." >> $logFile
	fi
done

# upload to netdisk
if [ -f $uploader ]; then
	$uploader upload $fnPkgFull $fnPkg
	if [ $? == 0 ]; then
		echo ">>> $fnPkg uploaded to netdisk."
		echo ">>> $fnPkg uploaded to netdisk." >> $logFile
	fi
fi

echo "All done!"
echo "Backup success!" >> $logFile
