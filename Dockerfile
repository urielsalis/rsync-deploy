FROM alpine:latest

RUN apk add --update rsync openssh-client

# Label
LABEL "com.github.actions.name"="Deploy with rsync"
LABEL "com.github.actions.description"="Deploy to a remote server using rsync over ssh"
LABEL "com.github.actions.color"="green"
LABEL "com.github.actions.icon"="truck"

LABEL "repository"="http://github.com/urielsalis/rsync-deploy"
LABEL "homepage"="https://github.com/urielsalis/rsync-deploy"
LABEL "maintainer"="Urielsalis <uriel@urielsalis.me>"


ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
