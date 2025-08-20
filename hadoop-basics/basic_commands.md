## Linux Commands - Key HDFS commands for file management

### Topics:

1. Creating and Viewing Directories 
2. Removing and Moving Files 
3. Viewing File Contents 
4. File Info and Permissions 
5. Uploading and Downloading Files 

The general syntax for Hadoop HDFS commands is: 

```bash
hdfs dfs -<command> [options] <source> [<destination>]
```

- `hdfs` : Calls Hadoop's file system interface 
- `dfs` : Specifies you're working with the Hadoop Distributed File System 
- `-<command>` :  The operation you want to perform (like `-ls`, `-mkdir`) 
- `<source>` and `<destination>` : Paths to HDFS or local files 

#### 1.1: Creating and Viewing Directories  

These hdfs dfs commands help you manage directories in the Hadoop Distributed File System (HDFS), like `mkdir`, `ls`, etc. in Linux. 

#### 1.1.1: Create a Directory

Syntax:

```bash
hdfs dfs -mkdir <HDFS directory path>
```

Example:

```bash
## Create a directory named "logs" under "/user/hadoop/" in HDFS

hdfs dfs -mkdir /user/hadoop/logs
```

#### 1.1.2: Create nested directories with parent paths 

Syntax:

```bash
hdfs dfs -mkdir -p <HDFS full directory path>
```

Example:

```bash
## Create "/data/2025/aug" along with any missing parent directories in one command

hdfs dfs -mkdir -p /user/hadoop/data/2025/aug
```

#### 1.1.3: View contents of a directory

Syntax:

```bash
hdfs dfs -ls <HDFS directory path>
```

Example:

```bash
## List all files and sub-directories directly under "/user/hadoop"

hdfs dfs -ls /user/hadoop/
```

#### 1.1.4: View contents recursively 

Syntax:

```bash
hdfs dfs -ls -R <HDFS directory path>
```

Example:

```bash
## List all directories and files under "/user/hadoop", including nested ones

hdfs dfs -ls -R /user/hadoop/
```

#### 1.1.5: Test if a directory exists

Syntax:

```bash
hdfs dfs -test -d <HDFS directory path>
```

Example:

```bash
## Check if "/user/hadoop/logs" exists.

hdfs dfs -test -d /user/hadoop/logs
```

#### 1.1.6: View directory metadata 

Syntax:

```bash
hdfs dfs -stat <HDFS directory path>
```

Example:

```bash
## Display size, modification time, and permission of the directory "/user/hadoop/logs"

hdfs dfs -stat /user/hadoop/logs
```

#### 2.2: Removing and Moving Files

HDFS commands for removing and moving files are given below 

#### 2.2.1: Remove a file 

Syntax:

```bash
hdfs dfs -rm <HDFS file path>
```

Example:

```bash
## To delete a file name "test1.txt" from "/user/hadoop/" directory in HDFS

hdfs dfs -rm /user/hadoop/file1.txt
```

#### 2.2.2: Remove a directory 

Syntax:

```bash
hdfs dfs -rm -r <HDFS directory path>
```

Example:

```bash
## Delete entire directory "/user/hadoop/logs" along with all its files and subdirectories

hdfs dfs -rm -r /user/hadoop/logs
```

#### 2.2.3: Skip trash when deleting (permanent delete) 

Syntax:

```bash
hdfs dfs -rm -r -skipTrash <HDFS directory path>
```

Example:

```bash
## Permanently delete the "/user/hadoop/tmp" directory without moving it to the HDFS trash

hdfs dfs -rm -r -skipTrash /user/hadoop/tmp
```

#### 2.2.4: Move a file to another directory 

Syntax: 

```bash
hdfs dfs -mv <source path> <destination path>
```

Example:

```bash
## Move a file name "file1.txt" from "/user/hadoop/" to the "/user/hadoop/archive" directory

hdfs dfs -mv /user/hadoop/file1.txt /user/hadoop/archive/
```

>**Note**: The above command can also be used to rename a directory.

#### 2.2.5: Rename a file

Synatx:

```bash
hdfs dfs -mv <source file name> <destination file name>
```

Example:

```bash
## Rename a file from "test1.txt" to "newfile1.txt"

hdfs dfs -mv /user/hadoop/test1.txt /user/hadoop/newfile1.txt
```

#### 2.3: Viewing File Contents  

#### 2.3.1: View the entire content of a file 

Syntax:

```bash
hdfs dfs -cat <HDFS file path>
```

Example:

```bash
## Display full content of the file "data.txt" stored at "/user/hadoop/"

hdfs dfs -cat /user/hadoop/data.txt
```

#### 2.3.2: View the first few bytes of a file 

Syntax:

```bash
hdfs dfs -head <HDFS file path>
```

Example:

```bash
## Display the beginning part of the file "app.log"

hdfs dfs -head /user/hadoop/logs/app.log
```

#### 2.3.3: View the last part of a file

Syntax:

```bash
hdfs dfs -tail <HDFS file path>
```

```bash
## Display the last part of the file "app.log"

hdfs dfs -tail /user/hadoop/logs/app.log
```

#### 2.3.4: View file block structure and locations 

Syntax:

```bash
hdfs fsck <HDFS file path> -files -blocks
```

Example:

```bash
## Check how "data.txt" is split into blocks and which DataNodes store them

hdfs fsck /user/hadoop/data.txt -files -blocks
```

#### 2.3.5: View file metadata (size, permissions, etc.)

Syntax:

```bash
hdfs dfs -stat <HDFS file path>
```

Example:

```bash
## Display metadata like filesize, last modified, and permission details of the file "data.txt"

hdfs dfs -stat /user/hadoop/data.txt
```

#### 2.4: File Info and Permissions 

#### 2.4.1: View detailed file or directory information 

Syntax:

```bash
hdfs dfs -ls -l <HDFS path>
```

Example:

```bash
## List the file "data.txt" with detailed information like permissions, owner, group, and filesize etc

hdfs dfs -ls -l /user/hadoop/data.txt
```

#### 2.4.2: Change file or directory permissions 

yntax:

```bash
hdfs dfs -chmod <permissions> <HDFS path>
```

Example:

```bash
## Change the permission of "/user/hadoop/scripts" to "rwxr-xr-x"

hdfs dfs -chmod 755 /user/hadoop/scripts
```

#### 2.4.3: Change file or directory owner and group 

Syntax:

```bash
hdfs dfs -chown <owner>:<group> <HDFS path>
```

Example:

```bash
## Change the owner of "data.txt" to user "hduser" and group "hduser"

hdfs dfs -chown hduser:hduser /user/hadoop/data.txt
```

#### 2.4.4: Change file or directory group only 

Syntax:

```bash
hdfs dfs -chgrp <group> <HDFS path>
```

Example:

```bash
## Change the group ownership of "data.txt" to "hduser"

hdfs dfs -chgrp hduser /user/hadoop/data.txt
```

#### 2.5: Uploading and Downloading Files 

#### 2.5.1: Upload a local file to HDFS 

Syntax:

```bash
hdfs dfs -put <local_file_path> <HDFS_destination_path>
```

Example:

```bash
## Upload the local file "data.txt" from "/home/hduser/" to the HDFS directory "/user/hadoop/"

hdfs dfs -put /home/hduser/data.txt /user/hadoop/
```

#### 2.5.2: Upload and overwrite an existing file in HDFS 

Syntax:

```bash
## Copy the local file "data.txt" to HDFS and overwrites if a file with the same name already exists

hdfs dfs --copyFromLocal -f <local_file_path> <HDFS_destination_path>
```

#### 2.5.3: Download a file from HDFS to local filesystem 

Syntax:

```bash
hdfs dfs -get <HDFS_file_path> <local_destination_path>
```

Example:

```bash
## Downloads the file "data.csv" from HDFS "/user/hadoop" to the local directory "/home/hduser/"

hdfs dfs -get /user/hadoop/data.csv /home/hduser
```

#### 2.5.4: Download a file and overwrite local copy

Syntax:

```bash
hdfs dfs -copyToLocal -f <HDFS_file_path> <local_destination_path>
```

Example:

```bash
## Copy the file from HDFS and overwrite the local file if it already exists

hdfs dfs -copyToLocal /user/hadoop/data.csv /home/hduser/
```

