#!/bin/bash

# Define HDFS base directory
HDFS_BASE_DIR="/user/hadoop"

echo "Setting up HDFS directories and files for testing..."

# 1. Creating and Viewing Directories Examples
echo -e "\n--- Setting up for Directory Examples ---"
hdfs dfs -mkdir -p ${HDFS_BASE_DIR}/data/2025/aug
hdfs dfs -mkdir -p ${HDFS_BASE_DIR}/logs
hdfs dfs -touchz ${HDFS_BASE_DIR}/file1.txt

# 2. Removing and Moving Files Examples
echo -e "\n--- Setting up for Removing and Moving Files Examples ---"
hdfs dfs -mkdir -p ${HDFS_BASE_DIR}/archive
hdfs dfs -mkdir -p ${HDFS_BASE_DIR}/tmp
hdfs dfs -touchz ${HDFS_BASE_DIR}/test1.txt
hdfs dfs -touchz ${HDFS_BASE_DIR}/file1.txt # Ensure file1.txt exists for mv example
hdfs dfs -touchz ${HDFS_BASE_DIR}/newfile1.txt # For renaming back if needed, or ensuring it exists for rename test

# 3. Viewing File Contents Examples
echo -e "\n--- Setting up for Viewing File Contents Examples ---"
# Create data.txt with 250 lines
DATA_FILE="/tmp/data.txt"
if [ -f "$DATA_FILE" ]; then
    rm "$DATA_FILE"
fi
for i in $(seq 1 250); do
  echo "This is the content of data.txt line $i." >> "$DATA_FILE"
done
hdfs dfs -put -f "$DATA_FILE" ${HDFS_BASE_DIR}/data.txt

# Create app.log with 250 lines
APP_LOG_FILE="/tmp/app.log"
if [ -f "$APP_LOG_FILE" ]; then
    rm "$APP_LOG_FILE"
fi
for i in $(seq 1 250); do
  if (( i % 10 == 0 )); then
    echo "ERROR: Something went wrong on line $i!" >> "$APP_LOG_FILE"
  elif (( i % 5 == 0 )); then
    echo "WARN: Potential issue on line $i." >> "$APP_LOG_FILE"
  else
    echo "INFO: Application log entry $i." >> "$APP_LOG_FILE"
  fi
done
hdfs dfs -put -f "$APP_LOG_FILE" ${HDFS_BASE_DIR}/logs/app.log
rm "$DATA_FILE" "$APP_LOG_FILE" # Clean up local temp files

# 4. File Info and Permissions Examples
echo -e "\n--- Setting up for File Info and Permissions Examples ---"
hdfs dfs -mkdir -p ${HDFS_BASE_DIR}/scripts
hdfs dfs -touchz ${HDFS_BASE_DIR}/data.txt # Ensure data.txt exists for permission changes

# 5. Uploading and Downloading Files Examples
echo -e "\n--- Setting up for Uploading and Downloading Files Examples ---"
# Create a local file for upload
echo "This is localdata.txt content." > /home/hduser/localdata.txt
# Create a local file that might be overwritten during download test
echo "Existing local file content." > /home/hduser/downloaded_localdata.txt
hdfs dfs -touchz ${HDFS_BASE_DIR}/localdata.txt # Create HDFS file for download tests

echo -e "\nSetup complete. You can now run the examples."
echo "To clean up the created HDFS data, you might use: hdfs dfs -rm -r ${HDFS_BASE_DIR}/data ${HDFS_BASE_DIR}/logs ${HDFS_BASE_DIR}/archive ${HDFS_BASE_DIR}/tmp ${HDFS_BASE_DIR}/scripts ${HDFS_BASE_DIR}/file1.txt ${HDFS_BASE_DIR}/test1.txt ${HDFS_BASE_DIR}/newfile1.txt ${HDFS_BASE_DIR}/data.txt ${HDFS_BASE_DIR}/localdata.txt"
echo "To clean up local files, you might use: rm /home/hduser/localdata.txt /home/hduser/downloaded_localdata.txt"