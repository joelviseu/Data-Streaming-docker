FROM apache/hive:2.3.10

USER root
COPY conf/hive-site.xml /opt/hive/conf/
COPY conf/core-site.xml /opt/hive/conf/
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]