# Hadoop High Availability Cluster with Docker Compose

This project provides a Docker Compose setup for running a **Hadoop 3.3.6** cluster in **High Availability (HA)** mode using **ZooKeeper-based failover**. The configuration includes:



# Highly Available Hadoop Cluster with Docker

This project sets up a **Highly Available (HA) Hadoop Cluster** using Docker. It includes configurations and scripts to deploy Hadoop with multiple NameNodes and DataNodes, ensuring fault tolerance and scalability.



- **config_ha/**: Contains Hadoop and ZooKeeper configuration files.
- **docker-compose.yml**: Defines the Docker services for the Hadoop cluster.
- **dockerfile**: Specifies the Docker image setup for Hadoop nodes.
- **entrypoint.sh**: Script executed when a Docker container starts.
- **ha_setup.sh**: Automates the setup of the HA Hadoop cluster.
- **Setup_HadoopCluster.txt**: Provides step-by-step instructions for manual cluster setup.

## 🧩 Components

- **ZooKeeper Nodes**: `zk1`, `zk2`, `zk3`
- **JournalNodes**: `jn1`, `jn2`, `jn3`
- **NameNodes**: `nn1`, `nn2`, `nn3` (all configured for automatic failover)
- **ResourceManagers**: integrated within masters, HA enabled
- **DataNode + NodeManager**: `dn1` (can be scaled horizontally)


## 🚀 Getting Started

Follow these steps to deploy the HA Hadoop Cluster:

### 1. Clone the Repository

```bash
git clone https://github.com/otifi3/Hadoop_HA.git
cd Hadoop_HA
```

### 2. Build the Cluster

```bash
docker-compose up --build
```

This command initializes the Hadoop cluster with:
- 🧠 3 NameNodes (`nn1`, `nn2`, `nn3`) using ZooKeeper-based failover
- 🗃️ 1 DataNode (`dn1`)
- 🐘 YARN ResourceManagers integrated into masters
- 🦓 3 ZooKeeper nodes (`zk1`, `zk2`, `zk3`) for automatic failover
- 📓 3 JournalNodes (`jn1`, `jn2`, `jn3`) required for shared edits in HDFS HA

### 3. Access the Web UIs

- HDFS NameNode: [http://localhost:9870](http://localhost:9870)
- YARN ResourceManager: [http://localhost:8088](http://localhost:8088)

> Make sure ports are not being blocked by firewall or other local services.

## ⚙️ Scaling the Cluster

To scale the number of DataNodes:

```bash
chmod +x scale_datanodes.sh
./scale_datanodes.sh <number of nodes>
```

## 🧹 Clean Up

To stop and remove all containers, networks, and volumes:

```bash
chmod +x cleanup.sh
./cleanup.sh
```

## 📌 Notes

- The setup includes logic to automatically format HDFS and ZooKeeper on the first run.
- Passwordless SSH is configured between containers for Hadoop services.
- You can modify or extend configurations in the `config_ha/` folder.
- The `ha_setup.sh` script handles role-based setup and service initiation.

## 👤 Author

Created by Ahmed Otifi  
🔗 GitHub: [https://github.com/otifi3](https://github.com/otifi3)

---

 

