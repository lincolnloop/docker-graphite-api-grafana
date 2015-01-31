# Graphite API + Grafana on Docker

A versioned, automated build of [graphite-api](http://graphite-api.readthedocs.org/) and [grafana](http://grafana.org/). The default settings will work out of the box for small installations where everything is running on one server and the default ports and locations are used.

If you need to override them, either write a new Dockerfile using `lincolnloop/graphite-api-grafana` as the base or add volumes at runtime:

```
docker run -v /path/to/grafana-config.js:/grafana/config.js \
           -v /path/to/graphite-api.yaml:/etc/graphite-api.yaml \
           --volumes-from=carbon \
           -p 8000:8000 \
           lincolnloop/graphite-api-grafana
```

Want to spin up a full working install with ElasticSearch and Carbon Cache? You can use [fig](http://www.fig.sh/) with a `fig.yml` that looks like this:

```
carbon:
  image: lincolnloop/carbon-cache
    ports:
      - "2003:2003"
      - "2004:2004"
    volumes:
      - /var/lib/whisper:/opt/graphite/storage/whisper
graphite:
  image: lincolnloop/graphite-api-grafana
  ports:
    - "8000:8000"
  links:
    - carbon
  volumes_from:
    - carbon
elasticsearch:
  image: lincolnloop/elasticsearch
  ports:
    - "9200:9200"
  volumes:
    - /var/lib/elasticsearch:/data
```
