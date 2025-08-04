To install and configure Hadoop YARN, first ensure Hadoop is already installed and configured. Log in to your Ubuntu Server using the username `admin` and password `admin` via SSH: `ssh admin@<virtual_machine_ip>`.

Once logged in, switch to the Hadoop user by typing `su - hduser` and entering the `hduser` password when prompted. Navigate to the Hadoop installation path: `cd /home/hduser/hadoop/etc/hadoop`.

### Enable MapReduce framework

1.  Open `mapred-site.xml` for editing: `nano mapred-site.xml`.

2.  Add the following property between the `<configuration></configuration>` tags:

    ```xml
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    ```

3.  Save and exit by pressing `Ctrl + X`, then `Enter` twice.

### Edit `yarn-site.xml`

1.  Open `yarn-site.xml` for editing: `nano yarn-site.xml`.

2.  Add the following properties inside the `<configuration>` tags:

    ```xml
    <configuration>
        <property>
            <name>yarn.nodemanager.aux-services</name>
            <value>mapreduce_shuffle</value>
        </property>
        <property>
            <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
            <value>org.apache.hadoop.mapred.ShuffleHandler</value>
        </property>
        <property>
            <name>yarn.resourcemanager.hostname</name>
            <value>localhost</value>
        </property>
        <property>
            <name>yarn.nodemanager.local-dirs</name>
            <value>file:///home/hduser/hadoopdata/yarn/local</value>
        </property>
        <property>
            <name>yarn.nodemanager.log-dirs</name>
            <value>file:///home/hduser/hadoopdata/yarn/logs</value>
        </property>
        <property>
            <name>yarn.resourcemanager.bind-host</name>
            <value>0.0.0.0</value>
            <description>The host that the ResourceManager will bind to. Setting this to 0.0.0.0 allows listening on all interfaces.</description>
        </property>
        <property>
            <name>yarn.nodemanager.bind-host</name>
            <value>0.0.0.0</value>
            <description>The host that the NodeManager will bind to. Setting this to 0.0.0.0 allows listening on all interfaces.</description>
        </property>
    </configuration>
    ```

### Format the HDFS Namenode

This step should only be performed once during the initial setup, as formatting a Namenode with existing data will erase it.

`hdfs namenode -format`

### Start Hadoop Services

1.  Start DFS services: `start-dfs.sh`
2.  Start YARN services: `start-yarn.sh`

### Verify services are running

Use the `jps` command to check running Java processes.

`jps`

Expected Output (similar to):

```
xxxx NameNode
xxxx DataNode
xxxx SecondaryNameNode
xxxx ResourceManager
xxxx NodeManager
xxxx Jps
```

## Installing and configuring Spark

### Create directory to install Spark

```bash
cd /home/hduser
mkdir spark
cd spark
```

### Download Spark from official site

`wget https://dlcdn.apache.org/spark/spark-3.5.6/spark-3.5.6-bin-hadoop3.tgz`

### Extract and move

```bash
tar -xvzf spark-3.5.6-bin-hadoop3.tgz
mv spark-3.5.6-bin-hadoop3/* .
rm -rf spark-3.5.6-bin-hadoop3
rm spark-3.5.6-bin-hadoop3.tgz
```

### Add Spark to environment path

1.  Open `~/.bashrc` for editing: `nano ~/.bashrc`

2.  Add the following content to the end of the file:

    ```bash
    export SPARK_HOME=/home/hduser/spark
    export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
    export PYSPARK_PYTHON=python3
    ```

3.  Apply Environment Variables: `source ~/.bashrc`

### Verify Spark Installation

  * To open Spark Shell: `spark-shell`
  * To exit from Spark Shell: `:quit` or `Ctrl + D`
  * To test the PySpark shell: `pyspark`
  * To exit from PySpark Shell: `exit()`

## Running a sample project

### Create a project directory

```bash
mkdir -p ~/hadoop-netflix-titles
cd ~/hadoop-netflix-titles
```

### Download dataset

```bash
wget https://files.example.com/file.tar.gz
tar -xvzf file.tar.gz
```

### Prepare HDFS Input Directory

Upload the `netflix_titles.csv` file to HDFS.

1.  Create directory: `hdfs dfs -mkdir -p /user/hduser/netflix_analysis/input`
2.  Input file: `hdfs dfs -put netflix_titles.csv /user/hduser/netflix_analysis/input/`

### Verify HDFS input

`hdfs dfs -ls /user/hduser/netflix_analysis/input`

You should see `netflix_titles.csv` listed.

### Submit the Spark Job to YARN

```bash
spark-submit \
--master yarn \
--deploy-mode client \
--driver-memory 1G \
--executor-memory 1G \
--num-executors 2 \
netflix_analysis.py
```

**Explanation of `spark-submit` arguments:**

  * `--master yarn`: Specifies that Spark should run on the YARN cluster manager.
  * `--deploy-mode client`: The Spark driver runs on the client machine where `spark-submit` is executed. Application output will appear in your console.
  * `--driver-memory 1G`: Allocates 1GB of memory for the Spark driver process.
  * `--executor-memory 1G`: Allocates 1GB of memory for each Spark executor process.
  * `--num-executors 2`: Requests 2 executor processes from YARN. Each executor runs on a NodeManager.
  * `netflix_analysis.py`: The path to your PySpark application script.

**During Execution:**

You will see Spark and Hadoop log messages in your terminal. The YARN ResourceManager UI (accessible at `http://<virtual_machine_ip>:8088`) will show an application named "NetflixContentAnalysis" in the "Running Applications" section. You can click on its Application ID to monitor progress, view logs, and see container details.

### Output Verification Steps

After the `spark-submit` command finishes successfully, verify the output.

**Verify HDFS Output Directory Structure**

The script writes output in Parquet format, partitioned by `release_year`.

`hdfs dfs -ls -R /user/hduser/netflix_analysis/output/yearly_content_counts_parquet`

**View Sample Output Content (using Spark Shell)**

You can use a temporary Spark Shell to read and inspect the generated Parquet files.

1.  Open Spark Shell: `spark-shell --master yarn`

2.  Once in the Spark Shell (Scala environment), execute:

    ```scala
    // Define the HDFS output path
    val hdfsOutputPath = "hdfs://localhost:9000/user/hduser/netflix_analysis/output/yearly_content_counts_parquet"

    // Read the Parquet data
    val df = spark.read.parquet(hdfsOutputPath)

    // Show the schema and some data
    df.printSchema()
    df.show(200, false) // Show up to 200 rows without truncation
    ```

**Expected Output:**

You should see a table with `release_year`, `type`, and `content_count` columns, displaying aggregated results. For example:

```
+------------+-------+-------------+
|release_year|type   |content_count|
+------------+-------+-------------+
|1925        |Movie  |1            |
|1942        |Movie  |2            |
|1943        |Movie  |3            |
|1944        |Movie  |3            |
|1945        |Movie  |3            |
|...         |...    |...          |
|2021        |Movie  |99           |
|2021        |TV Show|29           |
|2022        |Movie  |10           |
+------------+-------+-------------+
```

To exit Spark Shell: `:q`

### Clean Up (Optional)

To remove the created HDFS directories:

`hdfs dfs -rm -r /user/hduser/netflix_analysis`