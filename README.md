ELK Stack
========

This Image provides an **ELK Stack**, based on versions of 2015-03-22, which are:

- CentOS 7
- OpenJDK 8
- Logstash 1.5.1
- Elasticsearch 1.6.0
- Kibana 4.1.0

Usage
=====

This image uses **supervisor** to start the three components (Logstash, Elasticsearch, Kibana). The configurationfiles for supervisor are take from the **supervisor/** directory within the github repository, which are copied into the directory **/etc/supervisord.d/** on the image. Supervisord itself is configured, to **log** into the file **/var/log/supervisord.log**. This file is also preconfigured to be read by **logstash** and put into **elasticsearch**. 

When the container ist started, connect to the port **5601** and **kibana** will welcome you. Acknowledge the predefined index (logstash-\*) and you will see the **supervisord** logentries.

Every component is configured to log itself into the **/var/log/** directory.

Configuration
===========

There are three volumes, that you should be aware of:

- **/var/log**: Every component logs into this directory. It is strictly not necessary, but so it is a well defined place where logstash will find it's own logfiles.
- **/etc/logstash.d**: Put every configuration von logstash into this volume. The whole directory is read on startup.
- **/var/elasticsearch**: In this directory, elasticsearch will store everything. It's indexes and whatever it needs. Having this as a volume makes it possible to make the data persistent.

Containers from this image are meant to be a central logging solution for your service. By using **/etc/logstash.d** as a volume, you can centralize the logstash-configurations for every service.

