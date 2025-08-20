# Linux Commands - Key HDFS commands for file management

### Topics:

1. [Creating and Viewing Directories](#1-creating-and-viewing-directories)
2. [Removing and Moving Files](#2-removing-and-moving-files)
3. [Viewing File Contents](#3-viewing-file-contents)
4. [File Info and Permissions](#4-file-info-and-permissions)
5. [Uploading and Downloading Files](#5-uploading-and-downloading-files)

The general syntax for Hadoop HDFS commands is:

```bash
hdfs dfs -<command> [options] <source> [<destination>]
```

  - `hdfs`: Calls Hadoop's file system interface
  - `dfs`: Specifies you're working with the Hadoop Distributed File System
  - `-<command>`: The operation you want to perform (like `-ls`, `-mkdir`)
  - `<source>` and `<destination>`: Paths to HDFS or local files

-----

## 1. Creating and Viewing Directories

These `hdfs dfs` commands help you manage directories in the Hadoop Distributed File System (HDFS), similar to `mkdir`, `ls`, etc., in Linux.

### 1.1 Create a Directory

Syntax:

```bash
hdfs dfs -mkdir <HDFS_directory_path>
```

Example:

```bash
## Create a directory named "logs" under "/user/hadoop/" in HDFS

hdfs dfs -mkdir /user/hadoop/logs
```

### 1.2 Create Nested Directories with Parent Paths

Syntax:

```bash
hdfs dfs -mkdir -p <HDFS_full_directory_path>
```

Example:

```bash
## Create "/data/2025/aug" along with any missing parent directories in one command

hdfs dfs -mkdir -p /user/hadoop/data/2025/aug
```

### 1.3 View Contents of a Directory

Syntax:

```bash
hdfs dfs -ls <HDFS_directory_path>
```

Example:

```bash
## List all files and sub-directories directly under "/user/hadoop"

hdfs dfs -ls /user/hadoop/
```

### 1.4 View Contents Recursively

Syntax:

```bash
hdfs dfs -ls -R <HDFS_directory_path>
```

Example:

```bash
## List all directories and files under "/user/hadoop", including nested ones

hdfs dfs -ls -R /user/hadoop/
```

### 1.5 Test if a Directory Exists

Syntax:

```bash
hdfs dfs -test -d <HDFS_directory_path>
echo $?   # prints 0 if directory exists, 1 if it doesn’t
```

- `0` -> condition is `true`
- `1` -> condition is `false`

Example:

```bash
## Check if "/user/hadoop/logs" exists.

hdfs dfs -test -d /user/hadoop/logs
echo $?
```

> **Note**: The above command will be useful if you're writing a shell script like below:

```sh
if hdfs dfs -test -d /user/hadoop/logs; then
  echo "Directory exists"
else
  echo "Directory does not exist"
fi
```

### 1.6 View Directory Metadata

Syntax:

```bash
hdfs dfs -stat <HDFS_directory_path>
```

Example:

```bash
## Display size, modification time, and permission of the directory "/user/hadoop/logs"

hdfs dfs -stat /user/hadoop/logs
```

-----

## 2. Removing and Moving Files

HDFS commands for removing and moving files are given below:

### 2.1 Remove a File

Syntax:

```bash
hdfs dfs -rm <HDFS_file_path>
```

Example:

```bash
## To delete a file named "test1.txt" from "/user/hadoop/" directory in HDFS

hdfs dfs -rm /user/hadoop/file1.txt
```

### 2.2 Remove a Directory

Syntax:

```bash
hdfs dfs -rm -r <HDFS_directory_path>
```

Example:

```bash
## Delete the entire directory "/user/hadoop/logs" along with all its files and subdirectories

hdfs dfs -rm -r /user/hadoop/logs
```

### 2.3 Skip Trash when Deleting (Permanent Delete)

Syntax:

```bash
hdfs dfs -rm -r -skipTrash <HDFS_directory_path>
```

Example:

```bash
## Permanently delete the "/user/hadoop/tmp" directory without moving it to the HDFS trash

hdfs dfs -rm -r -skipTrash /user/hadoop/tmp
```

### 2.4 Move a File to Another Directory

Syntax:

```bash
hdfs dfs -mv <source_path> <destination_path>
```

Example:

```bash
## Move a file named "file1.txt" from "/user/hadoop/" to the "/user/hadoop/archive" directory

hdfs dfs -mv /user/hadoop/file1.txt /user/hadoop/archive/
```

> **Note**: The above command can also be used to rename a directory.

### 2.5 Rename a File

Syntax:

```bash
hdfs dfs -mv <source_file_name> <destination_file_name>
```

Example:

```bash
## Rename a file from "test1.txt" to "newfile1.txt"

hdfs dfs -mv /user/hadoop/test1.txt /user/hadoop/newfile1.txt
```

-----

## 3. Viewing File Contents

### 3.1 View the Entire Content of a File

Syntax:

```bash
hdfs dfs -cat <HDFS_file_path>
```

Example:

```bash
## Display full content of the file "data.txt" stored at "/user/hadoop/"

hdfs dfs -cat /user/hadoop/data.txt
```

### 3.2 View the First Few Bytes of a File

Syntax:

```bash
hdfs dfs -head <HDFS_file_path>
```

Example:

```bash
## Display the beginning part of the file "app.log"

hdfs dfs -head /user/hadoop/logs/app.log
```

### 3.3 View the Last Part of a File

Syntax:

```bash
hdfs dfs -tail <HDFS_file_path>
```

```bash
## Display the last part of the file "app.log"

hdfs dfs -tail /user/hadoop/logs/app.log
```

### 3.4 View File Block Structure and Locations

Syntax:

```bash
hdfs fsck <HDFS_file_path> -files -blocks
```

Example:

```bash
## Check how "data.txt" is split into blocks and which DataNodes store them

hdfs fsck /user/hadoop/data.txt -files -blocks
```

### 3.5 View File Metadata (size, permissions, etc.)

Syntax:

```bash
hdfs dfs -stat <HDFS_file_path>
```

Example:

```bash
## Display metadata like file size, last modified, and permission details of the file "data.txt"

hdfs dfs -stat /user/hadoop/data.txt
```

-----

## 4. File Info and Permissions

### 4.1 View Detailed File or Directory Information

Syntax:

```bash
hdfs dfs -ls -l <HDFS_path>
```

Example:

```bash
## List the file "data.txt" with detailed information like permissions, owner, group, and file size etc.

hdfs dfs -ls -l /user/hadoop/data.txt
```

### 4.2 Change File or Directory Permissions

Syntax:

```bash
hdfs dfs -chmod <permissions> <HDFS_path>
```

Example:

```bash
## Change the permission of "/user/hadoop/scripts" to "rwxr-xr-x"

hdfs dfs -chmod 755 /user/hadoop/scripts
```

### 4.3 Change File or Directory Owner and Group

Syntax:

```bash
hdfs dfs -chown <owner>:<group> <HDFS_path>
```

Example:

```bash
## Change the owner of "data.txt" to user "hduser" and group "hduser"

hdfs dfs -chown hduser:hduser /user/hadoop/data.txt
```

### 4.4 Change File or Directory Group Only

Syntax:

```bash
hdfs dfs -chgrp <group> <HDFS_path>
```

Example:

```bash
## Change the group ownership of "data.txt" to "hduser"

hdfs dfs -chgrp hduser /user/hadoop/data.txt
```

-----

## 5. Uploading and Downloading Files

### 5.1 Upload a Local File to HDFS

Syntax:

```bash
hdfs dfs -put <local_file_path> <HDFS_destination_path>
```

Example:

```bash
## Upload the local file "data.txt" from "/home/hduser/" to the HDFS directory "/user/hadoop/"

hdfs dfs -put /home/hduser/data.txt /user/hadoop/
```

### 5.2 Upload and Overwrite an Existing File in HDFS

Syntax:

```bash
hdfs dfs -copyFromLocal -f <local_file_path> <HDFS_destination_path>
```

Example:

```bash
## Copy the local file "data.txt" to HDFS and overwrites if a file with the same name already exists

hdfs dfs -copyFromLocal -f /home/hduser/data.txt /user/hadoop/
```

### 5.3 Download a File from HDFS to Local Filesystem

Syntax:

```bash
hdfs dfs -get <HDFS_file_path> <local_destination_path>
```

Example:

```bash
## Downloads the file "data.csv" from HDFS "/user/hadoop" to the local directory "/home/hduser/"

hdfs dfs -get /user/hadoop/data.csv /home/hduser
```

### 5.4 Download a File and Overwrite Local Copy

Syntax:

```bash
hdfs dfs -copyToLocal -f <HDFS_file_path> <local_destination_path>
```

Example:

```bash
## Copy the file from HDFS and overwrite the local file if it already exists

hdfs dfs -copyToLocal -f /user/hadoop/data.csv /home/hduser/
```