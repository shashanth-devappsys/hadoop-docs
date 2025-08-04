## Installing and Configuring HDFS on Linux (Ubuntu 24.04)

We will be using Ubuntu 24.04 running on VirtualBox to set up and configure the Hadoop HDFS. Please use the pre-configured Ubuntu image to start the installation. By using this image, we can directly focus on the installation and configuration of Hadoop. If we get stuck in between, we can drop the VM and start from fresh without bothering about the VM setup.

To install and configure Hadoop HDFS on Ubuntu 24.04, follow these steps:

#### 1. Log in to Ubuntu Server

- Username: `admin`
- Password: `admin`

```bash
ssh admin@<virtual_machine_ip>
## Enter password when prompted
```

#### 2: Create a Hadoop User

```bash
sudo adduser hduser
```

> When prompted, enter the password as: `hduser`

```bash
sudo usermod -aG sudo hduser
su - hduser
```

#### 3. Install Java (OpenJDK 17)

```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
java -version
```

#### 4. Find the Java Installation Path

```bash
readlink -f $(which java)
```

This command should return `/usr/lib/jvm/java-17-openjdk-amd64/bin/java`.

#### 5. Download and Extract Hadoop

```bash
cd /tmp
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz
tar -xvzf hadoop-3.4.1.tar.gz
mkdir -p ~/hadoop
mv hadoop-3.4.1/* ~/hadoop
```

#### 6. Set Environment Variables

Edit the `.bashrc` file:

```bash
nano ~/.bashrc
```

Add the following content to the end of the file:

```bash
export HADOOP_HOME=~/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

Exit the editor (`Ctrl` + `X` + `Enter` + `Enter`) and apply changes:

```bash
source ~/.bashrc
```

#### 7. Configure Hadoop for HDFS

Navigate to the Hadoop configuration directory:

```bash
cd ~/hadoop/etc/hadoop
```

Edit the `hadoop-env.sh` file:

```bash
nano hadoop-env.sh
```

Add the following content:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

Exit the editor (`Ctrl` + `X` + `Enter` + `Enter`).

Edit the `core-site.xml` file:

```bash
nano core-site.xml
```

Replace the existing `<configuration></configuration>` block with:

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
```

Edit the `hdfs-site.xml` file:

```bash
nano hdfs-site.xml
```

Add the following content:

```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>

    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///home/hduser/hadoopdata/namenode</value>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///home/hduser/hadoopdata/datanode</value>
    </property>
</configuration>
```

Create the necessary directories:

```bash
mkdir -p ~/hadoopdata/namenode
mkdir -p ~/hadoopdata/datanode
```

Format the `Namenode`:

```bash
hdfs namenode -format
```

#### 8. Generate SSH Key

```bash
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
```

#### 9. Add Public Key to Authorized Keys and Set Permissions

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
```

#### 10. Start/Stop HDFS

```bash
## Starting HDFS
start-dfs.sh

## Stopping HDFS
stop-dfs.sh
```

#### 11. Verify running daemons

    jps

You should see:

- `NameNode`
- `DataNode`
- `SecondaryNameNode`

#### 12. Access Hadoop Web UI

- `NameNode` UI: `http://<virtual_machine_ip>:9870`
- `SecondaryNameNode` UI: `http://<virtual_machine_ip>:9868`