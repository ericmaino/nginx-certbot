FROM certbot/certbot

RUN apk add bash
RUN apk add curl

ADD ./start-certbot.sh /start.sh
WORKDIR /home/certbot

ENTRYPOINT [ "/bin/bash", "/start.sh" ]