#!/bin/bash
sudo service ssh start
ssh-keyscan -H m1 m2 m3 >> ~/.ssh/known_hosts
echo "${HOSTNAME: -1}" > /usr/local/zookeeper/myid

if [[ "$HOSTNAME" == *"m"* ]]; then
    hdfs --daemon start journalnode && /usr/local/zookeeper/bin/zkServer.sh start
    sleep 3

    if [[ "$HOSTNAME" == "m1" ]]; then
        if [[ ! -d "/usr/local/hadoop/hdfs/namenode/current" ]]; then
            hdfs namenode -format -clusterId hadoop-cluster && hdfs zkfc -formatZK
        fi
        hdfs --daemon start namenode && hdfs --daemon start zkfc
        yarn --daemon start resourcemanager

    else
        if [[ ! -d "/usr/local/hadoop/hdfs/namenode/current" ]]; then
            sleep 5
            hdfs namenode -bootstrapStandby
        fi
        hdfs --daemon start namenode && hdfs --daemon start zkfc
        yarn --daemon start resourcemanager
    fi
elif [[ "$HOSTNAME" == *"s"* ]]; then
    hdfs --daemon start datanode && yarn --daemon start nodemanager
fi

tail -f /dev/null
