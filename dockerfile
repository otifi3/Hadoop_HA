FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt install -y sudo openjdk-8-jdk wget tar ssh && \
    apt clean


# Create hadoop user
RUN useradd -m -s /bin/bash hadoop && echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to working directory
WORKDIR /usr/local

# Download and extract Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz \
    && tar -xvzf hadoop-3.3.6.tar.gz \
    && mv hadoop-3.3.6 hadoop \
    && rm hadoop-3.3.6.tar.gz \
    && chown -R hadoop:hadoop /usr/local/hadoop

# Download and extract ZooKeeper
RUN wget https://downloads.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz \
    && tar -xvzf apache-zookeeper-3.9.3-bin.tar.gz \
    && mv apache-zookeeper-3.9.3-bin zookeeper \
    && rm apache-zookeeper-3.9.3-bin.tar.gz \
    && chown -R hadoop:hadoop /usr/local/zookeeper

# Create HDFS directories
RUN mkdir -p /usr/local/hadoop/hdfs/namenode /usr/local/hadoop/hdfs/datanode /usr/local/hadoop/journal \
    && chown -R hadoop:hadoop /usr/local/hadoop/hdfs /usr/local/hadoop/journal

# Copy configuration files
COPY config_ha/*.xml /usr/local/hadoop/etc/hadoop/
COPY config_ha/zoo.cfg /usr/local/zookeeper/conf/
COPY entrypoint.sh /home/hadoop/
COPY config_ha/workers /usr/local/hadoop/etc/hadoop/

RUN chmod +x /home/hadoop/entrypoint.sh
RUN chown -R hadoop:hadoop /home/hadoop/entrypoint.sh

# Switch to hadoop user
USER hadoop

# Set environment variables
RUN echo 'export HADOOP_HOME=/usr/local/hadoop' >> ~/.bashrc \
    && echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc \
    && echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> ~/.bashrc \
    && echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc \
    && echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc \
    && echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc \
    && echo 'export HADOOP_YARN_HOME=$HADOOP_HOME' >> ~/.bashrc \
    && echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc

# Configure Hadoop environment variables
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh \
    && echo "export HADOOP_HOME=/usr/local/hadoop" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh \
    && echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh \
    && echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

# 
EXPOSE 9870 8088




# Set working directory
WORKDIR /home/hadoop

RUN mkdir -p /home/hadoop/.ssh && ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -N "" 
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys

# RUN chmod 700 /home/hadoop/.ssh \
#     && chmod 600 /home/hadoop/.ssh/id_rsa \
#     && chmod 644 /home/hadoop/.ssh/id_rsa.pub \
#     && chmod 600 /home/hadoop/.ssh/authorized_keys \
#     && chown -R hadoop:hadoop /home/hadoop/.ssh

# RUN echo -e "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null\n" \
#     >> /home/hadoop/.ssh/config \
#     && chmod 600 /home/hadoop/.ssh/config \
#     && chown hadoop:hadoop /home/hadoop/.ssh/config

# Start shell
# ENTRYPOINT [ "/bin/bash", "-c", "sudo service ssh start; sleep infinity" ]

ENTRYPOINT [ "/home/hadoop/entrypoint.sh" ]