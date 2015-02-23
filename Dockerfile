FROM sumpfgottheit:centos7
MAINTAINER Florian Sachs "florian.sachs@gmx.at"

# Install Supervisor and Java
RUN yum -y install supervisor java-1.7.0-openjdk-headless

#
# INSTALL Elasticsearch, Logstash and Kibana
# 

# Install Logstash (from https://registry.hub.docker.com/u/pblittle/docker-logstash/dockerfile/)
RUN cd /tmp && \
	wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz && \
	tar xzvf logstash-1.4.2.tar.gz && \
	mv logstash-1.4.2 /opt/logstash && \
	chown -R root:root /opt/logstash && \
	rm logstash-1.4.2.tar.gz


# Install Elasticsearch from RPM Package
RUN cd /tmp && \
	wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.3.tar.gz && \
	tar xvfz elasticsearch-1.4.3.tar.gz && \
	mv elasticsearch-1.4.3 /opt/elasticsearch && \
	rm elasticsearch-1.4.3.tar.gz

# Install Kibana
RUN cd /tmp && \
	wget https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-rc1-linux-x64.tar.gz && \
	tar xvfz kibana-4.0.0-rc1-linux-x64.tar.gz && \
	mv kibana-4.0.0-rc1-linux-x64 /opt/kibana && \
	chown -R root:root /opt/kibana && \
	rm -f kibana-4.0.0-rc1-linux-x64.tar.gz

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
