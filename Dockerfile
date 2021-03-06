FROM alpine:3.11.3
RUN apk add --update --no-cache unzip wget busybox-suid shadow bash openjdk8 tzdata postgresql-client terminus-font msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f && \
    rm -rf /etc/localtime &&  mkdir -p /opt/pentaho && touch /etc/localtime /etc/timezone
WORKDIR /opt
RUN wget "https://sourceforge.net/projects/pentaho/files/Pentaho%209.0/server/pentaho-server-ce-9.0.0.0-423.zip"
RUN unzip *.zip && rm -rf *.zip
COPY ./configs/start.sh /usr/bin/start.sh
COPY ./configs/context.xml /opt/pentaho-server/tomcat/webapps/pentaho/META-INF/context.xml
COPY ./configs/repository.xml /opt/pentaho-server/pentaho-solutions/system/jackrabbit/repository.xml
COPY ./configs/postgresql.hibernate.cfg.xml /opt/pentaho-server/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml
COPY ./configs/hibernate-settings.xml /opt/pentaho-server/pentaho-solutions/system/hibernate/hibernate-settings.xml
COPY ./configs/startup.sh /opt/pentaho-server/tomcat/bin/startup.sh
RUN adduser -D -u 1001 s2i && usermod -aG 0 s2i && \
chown 1001 -R /opt/pentaho-server /usr/bin/start.sh /home/s2i && \
chgrp -R 0 /opt/pentaho-server /usr/bin/start.sh /etc/localtime /home/s2i /etc/timezone && \
chmod -R g=u /opt/pentaho-server /usr/bin/start.sh /etc/localtime /home/s2i /etc/timezone
ENV HOME /home/s2i
USER 1001
EXPOSE 8080 8009
ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["/opt/pentaho-server/start-pentaho.sh"]