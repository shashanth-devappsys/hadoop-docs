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


