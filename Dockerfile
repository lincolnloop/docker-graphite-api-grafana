FROM debian:jessie

ENV GRAPHITE_API_VERSION 1.0.1
ENV GRAFANA_VERSION 1.9.1

VOLUME /srv/graphite

RUN apt-get update -q &&  apt-get upgrade -y && apt-get install -y locales

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN apt-get install -y wget build-essential python-dev libffi-dev libcairo2-dev python-pip
RUN pip install -U pip
RUN pip install uwsgi graphite-api[sentry]==${GRAPHITE_API_VERSION}

RUN wget -qO- http://grafanarel.s3.amazonaws.com/grafana-${GRAFANA_VERSION}.tar.gz \
    | tar xvzf - && mv grafana-${GRAFANA_VERSION} grafana

ADD grafana-config.js /grafana/config.js

ADD graphite-api.yaml /etc/graphite-api.yaml

EXPOSE 8000

# Having problems with cached static files when using VirtualBox (boot2docker)?
# Add --disable-sendfile
CMD uwsgi --module=graphite_api.app:app --http=:8000 \
          --processes=2 --thunder-lock --enable-threads --master \
          --check-static=/grafana --static-index=index.html
