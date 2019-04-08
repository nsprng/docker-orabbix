FROM alpine:latest
MAINTAINER nsprng

#Set environment variable if you are behind a proxy:
#ENV http_proxy=http://proxy.example.com:80

#Install packages:
RUN apk add --no-cache openjdk8 unzip

#Copy Orabbix distro:
COPY orabbix-1.2.3.zip /

#Install Orabbix and clean conf folder, because we gonna use custom configs:
RUN mkdir -p /opt/orabbix && \
	unzip -d /opt/orabbix/ orabbix-1.2.3.zip && \
	chmod -R +x /opt/orabbix && \
	rm -f orabbix-1.2.3.zip && \
	rm -rf /opt/orabbix/conf/* 

#Create volume for custom configs:
VOLUME /opt/orabbix/conf

#Orabbix won't start if you run it from non-home directory:
WORKDIR /opt/orabbix

#Start Orabbix and send logs to foreground:
CMD ./run.sh && sleep 1 && tail -f logs/orabbix.log
