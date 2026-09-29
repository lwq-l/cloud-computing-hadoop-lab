FROM ghcr.io/apache/hadoop:3.5.0

# The official Apache image already contains Java 17 and Hadoop 3.5.0.
# Reset its service entrypoint so GitHub Codespaces can keep the
# development container alive and let the lab scripts start HDFS explicitly.
USER root
RUN mkdir -p /workspaces && chown -R hadoop:users /workspaces
USER hadoop
ENTRYPOINT []
CMD ["sleep", "infinity"]
