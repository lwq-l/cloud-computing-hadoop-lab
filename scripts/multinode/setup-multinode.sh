#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"

BASE="$HOME/hadoop-multi"
BASE_CONF="$HADOOP_HOME/etc/hadoop"

echo "[1/5] Prepare multi-node teaching directories"
mkdir -p "$BASE/conf/client" "$BASE/conf/namenode"          "$BASE/conf/dn1" "$BASE/conf/dn2" "$BASE/conf/dn3"          "$BASE/data/namenode" "$BASE/data/dn1" "$BASE/data/dn2" "$BASE/data/dn3"          "$BASE/logs/nn" "$BASE/logs/dn1" "$BASE/logs/dn2" "$BASE/logs/dn3"

for conf in client namenode dn1 dn2 dn3; do
  cp -a "$BASE_CONF/." "$BASE/conf/$conf/"
  if grep -q '^export JAVA_HOME=' "$BASE/conf/$conf/hadoop-env.sh"; then
    sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=$JAVA_HOME|" "$BASE/conf/$conf/hadoop-env.sh"
  else
    echo "export JAVA_HOME=$JAVA_HOME" >> "$BASE/conf/$conf/hadoop-env.sh"
  fi
done

echo "[2/5] Write common HDFS client configuration"
for conf in client namenode dn1 dn2 dn3; do
cat > "$BASE/conf/$conf/core-site.xml" <<'EOF'
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://127.0.0.1:9000</value>
  </property>
</configuration>
EOF
done

write_hdfs_site() {
  local conf="$1"
  local data_dir="$2"
  local xfer="$3"
  local http="$4"
  local ipc="$5"

  cat > "$BASE/conf/$conf/hdfs-site.xml" <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>3</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file://$BASE/data/namenode</value>
  </property>
  <property>
    <name>dfs.namenode.http-address</name>
    <value>0.0.0.0:9870</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file://$data_dir</value>
  </property>
  <property>
    <name>dfs.datanode.address</name>
    <value>0.0.0.0:$xfer</value>
  </property>
  <property>
    <name>dfs.datanode.http.address</name>
    <value>0.0.0.0:$http</value>
  </property>
  <property>
    <name>dfs.datanode.ipc.address</name>
    <value>0.0.0.0:$ipc</value>
  </property>
  <property>
    <name>dfs.permissions.enabled</name>
    <value>false</value>
  </property>
</configuration>
EOF
}

# Client/NameNode use the same replication policy; their DataNode ports are placeholders.
write_hdfs_site "client"   "$BASE/data/dn1" 9866 9864 9867
write_hdfs_site "namenode" "$BASE/data/dn1" 9866 9864 9867

# Three independent DataNodes on one Codespace, each with unique ports and storage.
write_hdfs_site "dn1" "$BASE/data/dn1" 9866 9864 9867
write_hdfs_site "dn2" "$BASE/data/dn2" 9966 9964 9967
write_hdfs_site "dn3" "$BASE/data/dn3" 10066 10064 10067

echo "[3/5] Format the multi-node NameNode on first use"
if [ ! -f "$BASE/data/namenode/current/VERSION" ]; then
  HADOOP_CONF_DIR="$BASE/conf/namenode"   HADOOP_IDENT_STRING="multi-nn"   HADOOP_LOG_DIR="$BASE/logs/nn"   hdfs namenode -format -force -nonInteractive >/tmp/hadoop-multi-format.log 2>&1
  echo "Multi-node NameNode formatted."
else
  echo "Multi-node NameNode already formatted."
fi

echo "[4/5] Create activation helper"
cat > "$BASE/activate.sh" <<EOF
export HADOOP_HOME=$HADOOP_HOME
export JAVA_HOME=$JAVA_HOME
export HADOOP_CONF_DIR=$BASE/conf/client
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:\$PATH
EOF

echo "[5/5] Done"
echo
echo "Multi-node environment prepared:"
echo "  NameNode : RPC 9000 / Web 9870"
echo "  DataNode1: xfer 9866 / web 9864 / ipc 9867"
echo "  DataNode2: xfer 9966 / web 9964 / ipc 9967"
echo "  DataNode3: xfer 10066 / web 10064 / ipc 10067"
echo
echo "Next: bash scripts/multinode/start-multinode.sh"
