#!/usr/bin/env bash
set -euo pipefail

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

echo "[1/5] Configure JAVA_HOME"
if grep -q '^export JAVA_HOME=' "$HADOOP_CONF_DIR/hadoop-env.sh"; then
  sed -i 's|^export JAVA_HOME=.*|export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64|' "$HADOOP_CONF_DIR/hadoop-env.sh"
else
  echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> "$HADOOP_CONF_DIR/hadoop-env.sh"
fi

echo "[2/5] Configure single-node HDFS"
cat > "$HADOOP_CONF_DIR/core-site.xml" <<'EOF'
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF

cat > "$HADOOP_CONF_DIR/hdfs-site.xml" <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file://$HOME/hdfs-data/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file://$HOME/hdfs-data/datanode</value>
  </property>
  <property>
    <name>dfs.namenode.http-address</name>
    <value>0.0.0.0:9870</value>
  </property>
</configuration>
EOF

echo "[3/5] Configure passwordless SSH to localhost"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  ssh-keygen -q -t rsa -N '' -f "$HOME/.ssh/id_rsa"
fi
cat "$HOME/.ssh/id_rsa.pub" >> "$HOME/.ssh/authorized_keys"
sort -u "$HOME/.ssh/authorized_keys" -o "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"
cat > "$HOME/.ssh/config" <<'EOF'
Host localhost
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
chmod 600 "$HOME/.ssh/config"

echo "[4/5] Prepare HDFS directories"
mkdir -p "$HOME/hdfs-data/namenode" "$HOME/hdfs-data/datanode"

if [ ! -f "$HOME/hdfs-data/namenode/current/VERSION" ]; then
  echo "Formatting NameNode for the first time..."
  hdfs namenode -format -force -nonInteractive >/tmp/hdfs-format.log 2>&1
else
  echo "NameNode already formatted; skipping format."
fi

echo "[5/5] Prepare sample data"
mkdir -p data
if [ ! -f data/hello.txt ]; then
  printf 'Hello Hadoop\nCloud Computing Lab\n' > data/hello.txt
fi

cat > "$HOME/.hadoop_lab_env" <<'EOF'
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export PATH=/opt/hadoop/bin:/opt/hadoop/sbin:$PATH
EOF

if ! grep -q '.hadoop_lab_env' "$HOME/.bashrc"; then
  echo '[ -f "$HOME/.hadoop_lab_env" ] && source "$HOME/.hadoop_lab_env"' >> "$HOME/.bashrc"
fi

echo
echo "Hadoop teaching environment is ready."
echo "Next: ./scripts/start-hdfs.sh"
