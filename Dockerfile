FROM neo4j:3.0.2-enterprise

ENV STUNNEL_VERSION 5.32

RUN apt-get update && apt-get install -y gcc make libssl-dev net-tools

ADD healthcheck.sh /healthcheck.sh
RUN wget https://www.stunnel.org/downloads/stunnel-${STUNNEL_VERSION}.tar.gz && \
    tar xvf stunnel-${STUNNEL_VERSION}.tar.gz && \
    cd stunnel-${STUNNEL_VERSION} && \
    ./configure && \
    make && make install
RUN mkdir -p /var/run/stunnel && chown nobody:nogroup /var/run/stunnel
ADD stunnel.conf /usr/local/etc/stunnel/stunnel.conf
ADD test-key.pem /etc/stunnel/private.pem
RUN apt-get remove -y gcc make
#append stunnel startup to the neo4j startup script
RUN sed -i '/#!\/bin\/bash/a stunnel& #start stunnel before starting neo4j' /docker-entrypoint.sh
