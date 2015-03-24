FROM sumpfgottheit/centos7
MAINTAINER Florian Sachs "florian.sachs@gmx.at"

# Install Supervisor and Java
RUN yum -y install supervisor java-1.7.0-openjdk-headless

#
# INSTALL Elasticsearch, Logstash and Kibana
# 

# Install Logstash (from https://registry.hub.docker.com/u/pblittle/docker-logstash/dockerfile/)
ENV LS=logstash-1.4.2
RUN cd /tmp && \
	wget https://download.elasticsearch.org/logstash/logstash/${LS}.tar.gz && \
	echo "d59ef579c7614c5df9bd69cfdce20ed371f728ff  ${LS}.tar.gz" > sha1sum.txt && \
	sha1sum -c sha1sum.txt &&  rm sha1sum.txt && \
	tar xzvf ${LS}.tar.gz && \
	mv ${LS} /opt/logstash && \
	chown -R root:root /opt/logstash && \
	rm ${LS}.tar.gz


# Install Elasticsearch 
ENV ES=elasticsearch-1.4.4
RUN cd /tmp && \
	wget https://download.elasticsearch.org/elasticsearch/elasticsearch/${ES}.tar.gz && \
	echo "963415a9114ecf0b7dd1ae43a316e339534b8f31  ${ES}.tar.gz" > sha1sum.txt && \
	sha1sum -c sha1sum.txt &&  rm sha1sum.txt && \
	tar xvfz ${ES}.tar.gz && \
	mv ${ES} /opt/elasticsearch && \
	rm ${ES}.tar.gz

# Install Kibana
ENV KIBANA=kibana-4.0.1-linux-x64
RUN cd /tmp && \
	wget https://download.elasticsearch.org/kibana/kibana/${KIBANA}.tar.gz && \
	echo "1b8914c62a606b7103295a4e3ab01ec40c9993ed  ${KIBANA}.tar.gz" > sha1sum.txt && \
	sha1sum -c sha1sum.txt &&  rm sha1sum.txt && \
	tar xvfz ${KIBANA}.tar.gz && \
	mv ${KIBANA} /opt/kibana && \
	chown -R root:root /opt/kibana && \
	rm -f ${KIBANA}.tar.gz

#
# Building the Configuration for Elasticsearch, Logstash an Kibana 
#

# Logstash
ENV LOGSTASH_CONF_DIR=/etc/logstash.d/
RUN mkdir -p $LOGSTASH_CONF_DIR
ADD logstash_minimal.conf $LOGSTASH_CONF_DIR/_minimal.conf

# Elasticsearch
ENV ELASTICSEARCH_DATA_DIR=/var/elasticsearch
RUN mkdir -p $ELASTICSEARCH_DATA_DIR

# Copy the supervisord to the container
COPY supervisor/*.ini /etc/supervisord.d/
RUN sed -r -i 's#logfile=/var/log/supervisor/supervisord.log#logfile=/var/log/supervisord.log#' /etc/supervisord.conf

# Expose the Kibana Port
EXPOSE 5601 

# Clean everything that yum left behind
RUN yum -y clean all

VOLUME ["/var/log", "/etc/logstash.d", "/var/elasticsearch"]

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]
