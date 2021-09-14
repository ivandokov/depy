FROM bash:5

RUN apk --no-cache add rsync openssh-client zip \
    && ln -s /opt/depy/depy /usr/local/bin/depy \
    && mkdir /deploy

COPY depy /opt/depy/
COPY help /opt/depy/
COPY ignore /opt/depy/
COPY .depy /opt/depy/
COPY .depy-pre.sh /opt/depy/
COPY .depy-remote.sh /opt/depy/
COPY .depy-post.sh /opt/depy/
COPY .depyignore /opt/depy/

WORKDIR /deploy

ENTRYPOINT ["depy"]
