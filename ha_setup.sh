apt update
apt install -y sudo
apt install -y openjdk-8-jdk
apt install -y wget
apt install -y tar
apt clean

useradd -m -s /bin/bash hadoop

cd /usr/local
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
tar -xvzf hadoop-3.3.6.tar.gz
mv hadoop-3.3.6 hadoop
rm hadoop-3.3.6.tar.gz
chown -R hadoop:hadoop /usr/local/hadoop

wget https://downloads.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz
tar -xvzf apache-zookeeper-3.9.3-bin.tar.gz
mv apache-zookeeper-3.9.3-bin zookeeper
rm apache-zookeeper-3.9.3-bin.tar.gz
chown -R hadoop:hadoop /usr/local/zookeeper

mkdir -p /usr/local/hadoop/hdfs/namenode
mkdir -p /usr/local/hadoop/hdfs/datanode
mkdir -p /usr/local/hadoop/journal
chown -R hadoop:hadoop /usr/local/hadoop/hdfs
chown -R hadoop:hadoop /usr/local/hadoop/journal

cp config_ha/*.xml /usr/local/hadoop/etc/hadoop/
cp config_ha/zoo.cfg /usr/local/zookeeper/conf/


su - hadoop

echo 'export HADOOP_HOME=/usr/local/hadoop' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc
echo 'export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME=/usr/local/hadoop' >> ~/.bashrc
echo 'export HADOOP_COMMON_HOME=/usr/local/hadoop' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME=/usr/local/hadoop' >> ~/.bashrc
echo 'export HADOOP_YARN_HOME=/usr/local/hadoop' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin' >> ~/.bashrc
source ~/.bashrc

echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
echo 'export HADOOP_HOME=/usr/local/hadoop' >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
echo 'export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop' >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
echo 'export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin' >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh




# Run on ALL Masters (m1,m2,m3)
sudo service ssh start
ssh-keyscan -H m1 m2 m3 >> ~/.ssh/known_hosts
echo "${HOSTNAME: -1}" > /usr/local/zookeeper/myid
hdfs --daemon start journalnode && /usr/local/zookeeper/bin/zkServer.sh start

# Run ONLY on active NameNode (m1)
hdfs namenode -format -clusterId hadoop-cluster && hdfs zkfc -formatZK   # Run only run on m1 first time only
hdfs --daemon start namenode  && hdfs --daemon start zkfc

# Run on standby NameNodes (m2,m3)
hdfs namenode -bootstrapStandby   # Run only run on m2,m3 after m1 is up and first time only
hdfs --daemon start namenode  && hdfs --daemon start zkfc


# Start ALL 3 ResourceManagers
yarn --daemon start resourcemanager


# Run on ALL DataNodes
hdfs --daemon start datanode
yarn --daemon start nodemanager

# Check the status of the cluster
yarn rmadmin -getServiceState rm1  
yarn node -list               
hdfs haadmin -getServiceState nn1  
hdfs dfsadmin -report

yarn rmadmin -getAllServiceState
hdfs haadmin -getAllServiceState

# Stop the services
yarn --daemon stop resourcemanager  
hdfs --daemon stop namenode 