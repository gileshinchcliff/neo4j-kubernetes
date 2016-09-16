FROM neo4j:3.0.4-enterprise

RUN apt-get update && apt-get -y install net-tools awscli
ADD healthcheck.sh /healthcheck.sh
ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD neo4j.conf /var/lib/neo4j/conf/neo4j.conf
ADD migration.sh /migration.sh
