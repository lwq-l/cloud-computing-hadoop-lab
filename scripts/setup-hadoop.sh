#!/usr/bin/env bash
set -euo pipefail

export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"

echo "[1/4] Configure Hadoop environment"
mkdir -p "$HADOOP_CONF_DIR"
if [ -f "$HADOOP_CONF_DIR/hadoop-env.sh" ]; then
  if grep -q '^export JAVA_HOME=' "$HADOOP_CONF_DIR/hadoop-env.sh"; then
    sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=$JAVA_HOME|" "$HADOOP_CONF_DIR/hadoop-env.sh"
  else
    echo "export JAVA_HOME=$JAVA_HOME" >> "$HADOOP_CONF_DIR/hadoop-env.sh"
  fi
fi

echo "[2/4] Configure single-node HDFS"
cat > "$HADOOP_CONF_DIR/core-site.xml" <<'EOF'
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://127.0.0.1:9000</value>
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

echo "[3/4] Prepare HDFS data directories"
mkdir -p "$HOME/hdfs-data/namenode" "$HOME/hdfs-data/datanode"
if [ ! -f "$HOME/hdfs-data/namenode/current/VERSION" ]; then
  echo "Formatting NameNode for first use..."
  hdfs namenode -format -force -nonInteractive >/tmp/hdfs-format.log 2>&1
else
  echo "NameNode already formatted."
fi

echo "[4/4] Write shell environment"
cat > "$HOME/.hadoop_lab_env" <<EOF
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_CONF_DIR
export JAVA_HOME=$JAVA_HOME
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:\$PATH
EOF

if ! grep -q '.hadoop_lab_env' "$HOME/.bashrc" 2>/dev/null; then
  echo '[ -f "$HOME/.hadoop_lab_env" ] && source "$HOME/.hadoop_lab_env"' >> "$HOME/.bashrc"
fi

echo
echo "Environment ready."
echo "Run: bash scripts/start-hdfs.sh"
