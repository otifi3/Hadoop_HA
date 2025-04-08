FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables (shared for user & config)
ENV HADOOP_HOME=/usr/local/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install dependencies
RUN apt update && \
    apt install -y sudo openjdk-8-jdk ssh && \
    apt clean

# Create non-root user (hadoop)
RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /usr/local

# Download and extract Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz \
    && tar -xvzf hadoop-3.3.6.tar.gz \
    && mv hadoop-3.3.6 $HADOOP_HOME \
    && rm hadoop-3.3.6.tar.gz \
    && chown -R hadoop:hadoop $HADOOP_HOME

# Download and extract ZooKeeper
RUN wget https://downloads.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz \
    && tar -xvzf apache-zookeeper-3.9.3-bin.tar.gz \
    && mv apache-zookeeper-3.9.3-bin /usr/local/zookeeper \
    && rm apache-zookeeper-3.9.3-bin.tar.gz \
    && chown -R hadoop:hadoop /usr/local/zookeeper

# Create HDFS and JournalNode directories
RUN mkdir -p $HADOOP_HOME/hdfs/namenode $HADOOP_HOME/hdfs/datanode $HADOOP_HOME/journal && \
    chown -R hadoop:hadoop $HADOOP_HOME/hdfs $HADOOP_HOME/journal

# Copy configuration files
COPY config_ha/*.xml $HADOOP_HOME/etc/hadoop/
COPY config_ha/workers $HADOOP_HOME/etc/hadoop/
COPY config_ha/zoo.cfg /usr/local/zookeeper/conf/
COPY entrypoint.sh /home/hadoop/entrypoint.sh
COPY health_check.sh /home/hadoop/health_check.sh

# Fix permissions and make entrypoint executable
RUN chmod +x /home/hadoop/entrypoint.sh && \
    chown hadoop:hadoop /home/hadoop/entrypoint.sh && \
    chmod +x /home/hadoop/health_check.sh && \
    chown hadoop:hadoop /home/hadoop/health_check.sh

# Add JAVA_HOME to hadoop-env.sh
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Expose ports
EXPOSE 9870 8088

# Set working directory for hadoop user
WORKDIR /home/hadoop

# Switch to non-root user
USER hadoop

RUN mkdir -p /home/hadoop/.ssh && ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -N "" 
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys

# Set entrypoint
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]