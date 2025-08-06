To install and configure Hadoop YARN, first ensure Hadoop is already installed and configured. Log in to your Ubuntu Server using the username `admin` and password `admin` via SSH: `ssh admin@<virtual_machine_ip>`.

Once logged in, switch to the Hadoop user by typing `su - hduser` and entering the `hduser` password when prompted. Navigate to the Hadoop installation path: `cd /home/hduser/hadoop/etc/hadoop`.

Make sure the Hadoop home path is set in the environment.

    echo $HADOOP_HOME

The above commmand should return result `/home/hduser/hadoop`

Set Environment Variables
Edit your `~/.bashrc` file to set `HADOOP_OPTS`.

    nano ~/.bashrc

Add the below line to the end of the file

    ## ...
    ## existing Hadoop config
    ## ...
    export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

Press `Ctrl` + `X` + `Enter` + `Enter` to save and exit from the editor.

Reload changes

    source ~/.bashrc

Start Hadoop Daemons

    start-dfs.sh
    start-yarn.sh   

Verify running processes

    jps

Apache Hive Installation and Setup

Download Hive:

    cd ~/
    wget https://dlcdn.apache.org/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz
    tar -xvzf apache-hive-4.0.1-bin.tar.gz
    mv apache-hive-4.0.1-bin hive
    rm apache-hive-4.0.1-bin.tar.gz

Set Environment Variables for Hive

Edit your ~/.bashrc again.

    nano ~/.bashrc

Add the following lines

    export HIVE_HOME=$HOME/hive
    export PATH=$PATH:$HIVE_HOME/bin

Save, exit, and reload the `.bashrc` file

    source ~/.bashrc

Configure Hive Metastore (Derby):

Hive needs a metastore to store metadata about tables, partitions, etc.

Create Hive configuration directory

    mkdir -p ~/hive/conf

Switch to newly created directory and create `hive-site.xml` file

    cd ~/hive/conf
    nano hive-site.xml

Add the following content

    <configuration>
        <property>
            <name>javax.jdo.option.ConnectionURL</name>
            <value>jdbc:derby:;databaseName=/home/hduser/hive_metastore;create=true</value>
            <description>JDBC connect string for a JDBC metastore</description>
        </property>
        <property>
            <name>javax.jdo.option.ConnectionDriverName</name>
            <value>org.apache.derby.jdbc.EmbeddedDriver</value>
            <description>Driver class name for a JDBC metastore</description>
        </property>
        <property>
            <name>hive.metastore.warehouse.dir</name>
            <value>/user/hive/warehouse</value>
            <description>location of default database for the warehouse</description>
        </property>
        <property>
                <name>hive.server2.enable.doAs</name>
                <value>false</value>
        </property>
        <property>
                <name>hive.server2.thrift.bind.host</name>
                <value>localhost</value>
        </property>
        <property>
                <name>hive.server2.thrift.port</name>
                <value>10000</value>
        </property>
    </configuration>

Save and exit by hitting `Ctrl` + `X` + `Y` + `Enter` + `Enter`

Create HDFS directories for Hive

    hdfs dfs -mkdir /tmp
    hdfs dfs -mkdir -p /user/hive/warehouse
    hdfs dfs -chmod g+w /tmp
    hdfs dfs -chmod g+w /user/hive/warehouse

Initialize the Metastore

    schematool -dbType derby -initSchema --verbose

This command initializes the Derby database for Hive. You might see some warnings, but as long as it finishes with "Schema initialization completed", you're good.

Start HiveServer2

The most common way to start HiveServer2 is using the `hiveserver2` command. But starting and stopping the services will be difficult. So, we will create `start-hiveserver2.sh` and `stop-hiveserver2.sh` scripts to manage service.

Create `start-hiveserver2.sh` file

    ## Switch to Hive installation path
    cd ~/hive/bin

    ## Create file
    nano start-hiveserver2.sh

This script will start HiveServer2 in the background using nohup (to allow it to run even after you close your terminal) and redirect its output to a log file.

    #!/bin/bash

    # Define HIVE_HOME if not already set in your environment
    export HIVE_HOME=${HIVE_HOME:-/home/hduser/hive} 

    # Define a log directory for HiveServer2
    HIVESERVER2_LOG_DIR="$HIVE_HOME/logs"
    HIVESERVER2_LOG_FILE="$HIVESERVER2_LOG_DIR/hiveserver2.log"
    HIVESERVER2_PID_FILE="$HIVESERVER2_LOG_DIR/hiveserver2.pid" # Optional: to store PID for easier stopping

    # Create the log directory if it doesn't exist
    mkdir -p "$HIVESERVER2_LOG_DIR"

    echo "Starting HiveServer2..."

    # Check if HiveServer2 is already running
    if [ -f "$HIVESERVER2_PID_FILE" ]; then
        PID=$(cat "$HIVESERVER2_PID_FILE")
        if ps -p "$PID" > /dev/null; then
            echo "HiveServer2 (PID $PID) is already running."
            exit 0
        else
            echo "Stale PID file found. Removing it."
            rm -f "$HIVESERVER2_PID_FILE"
        fi
    fi

    # Start HiveServer2 in the background using nohup
    # hive --service hiveserver2 is a common way to invoke it for older Hive versions
    # For newer versions (Hive 1.2+), simply `hiveserver2` command is preferred.
    # Append output to the log file
    nohup "$HIVE_HOME"/bin/hiveserver2 >> "$HIVESERVER2_LOG_FILE" 2>&1 &
    echo $! > "$HIVESERVER2_PID_FILE" # Store the PID of the background process

    echo "HiveServer2 started. Check logs at: $HIVESERVER2_LOG_FILE"
    echo "You can check its status using: jps"

Create `stop-hiveserver2.sh` file

This script will attempt to stop HiveServer2 gracefully using the PID file created by the start script.

    #!/bin/bash

    # Define HIVE_HOME (must match the start script)
    export HIVE_HOME=${HIVE_HOME:-/home/hduser/hive} 

    HIVESERVER2_LOG_DIR="$HIVE_HOME/logs"
    HIVESERVER2_PID_FILE="$HIVESERVER2_LOG_DIR/hiveserver2.pid"

    echo "Stopping HiveServer2..."

    if [ -f "$HIVESERVER2_PID_FILE" ]; then
        PID=$(cat "$HIVESERVER2_PID_FILE")
        if ps -p "$PID" > /dev/null; then
            echo "Killing HiveServer2 process (PID: $PID)..."
            kill "$PID"
            # Wait a bit for the process to terminate
            sleep 5
            if ps -p "$PID" > /dev/null; then
                echo "HiveServer2 (PID: $PID) did not terminate gracefully. Forcing kill."
                kill -9 "$PID" # Force kill if it's still running
            fi
            rm -f "$HIVESERVER2_PID_FILE"
            echo "HiveServer2 stopped."
        else
            echo "HiveServer2 is not running (PID file exists but process not found)."
            rm -f "$HIVESERVER2_PID_FILE"
        fi
    else
        echo "HiveServer2 PID file not found. Is it running?"
    fi

Make them executable

    chmod +x start-hiveserver2.sh
    chmod +x stop-hiveserver2.sh

After running start-hiveserver2.sh, you can verify it's running using:

- jps (look for a RunJar process which is typically HiveServer2)
- sudo netstat -plnt | grep 10000 (should now show a process listening on 10000)
- tail -f $HIVE_HOME/logs/hiveserver2.log to see the real-time logs.

Start Hive CLI

    hive

To exit from the Hive CLI, type `!exit` and hit `Enter`

Sample project

We'll be using NASA access log dataset for the sample project.

Download the dataset

    cd /tmp
    wget https://ita.ee.lbl.gov/traces/NASA_access_log_Jul95.gz

Uncompress the file

    gunzip NASA_access_log_Jul95.gz

This will create a` NASA_access_log_Jul95` file.

Upload to HDFS

    # Create a directory in HDFS
    hdfs dfs -mkdir /user/hive/warehouse/nasa_logs 

    # Upload the file
    hdfs dfs -put NASA_access_log_Jul95 /user/hive/warehouse/nasa_logs/ 

Define a Hive Table:

You'll then need to create a Hive table that matches the schema of the log file. This log file contains various fields like host, timestamp, request, status, and bytes. You'll likely want to use a ROW FORMAT SERDE for regular expression (regex) to parse the unstructured log lines.

For example, a simplified table creation might look something like this (you'll need to refine the regex based on the exact log format, but this gives you an idea):



!connect jdbc:hive2://localhost:10000/default