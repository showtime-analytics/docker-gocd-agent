# GoCD Agent Docker image

[GoCD agent](https://www.gocd.io) docker image based on alpine 3.5 with Docker installed.

## Usage

Start the container with this:

```
docker run -d -e GO_SERVER_URL=... showtimeanalytics/gocd-agent:17.4.0
```

**Note:** Please make sure to *always* provide the version. We do not publish the `latest` tag. And we don't intend to.

This will start the GoCD agent and connect it the GoCD server specified by `GO_SERVER_URL`.

> **Note**: The `GO_SERVER_URL` must be an HTTPS url and end with `/go`, for e.g. `https://ip.add.re.ss:8154/go`

## Usage with docker GoCD server

If you have a [gocd-server container](https://hub.docker.com/r/gocd/gocd-server/) running and it's named `angry_feynman`, you can connect a gocd-agent container to it by doing:

```
docker run -itd -e GO_SERVER_URL=https://$(docker inspect --format='{{(index (index .NetworkSettings.IPAddress))}}' angry_feynman):$(docker inspect --format='{{(index (index .NetworkSettings.Ports "8154/tcp") 0).HostPort}}' angry_feynman)/go showtimeanalytics/gocd-agent:17.4.0
```

## Available configuration options

### Auto-registering the agents

```
docker run -d \
        -e AGENT_AUTO_REGISTER_KEY=... \
        -e AGENT_AUTO_REGISTER_RESOURCES=... \
        -e AGENT_AUTO_REGISTER_ENVIRONMENTS=... \
        -e AGENT_AUTO_REGISTER_HOSTNAME=... \
        showtimeanalytics/gocd-agent:17.4.0
```

If the `AGENT_AUTO_REGISTER_*` variables are provided (we recommend that you do), then the agent will be automatically approved by the server. See the [auto registration docs](https://docs.gocd.io/current/advanced_usage/agent_auto_register.html) on the GoCD website.

### Usage with docker and swarm elastic agent plugins

This image will work well with the [docker elastic agent plugin](https://github.com/gocd-contrib/docker-elastic-agents) and the [docker swarm elastic agent plugin](https://github.com/gocd-contrib/docker-swarm-elastic-agents). No special configuration would be needed.

### Mounting volumes

The GoCD agent will store all configuration, logs and perform builds in `/data`. If you'd like to provide secure credentials like SSH private keys among other things, you can mount `/opt/gocd`.

```
docker run -v /path/to/godata:/data -v /path/to/home-dir:/opt/gocd showtimeanalytics/gocd-agent:17.4.0
```

> **Note:** Ensure that `/path/to/home-dir` and `/path/to/godata` are accessible by the `gocd` user in container (`go` user - uid 10014).

### Tweaking JVM options (memory, heap etc)

JVM options can be tweaked using the environment variable `GO_AGENT_SYSTEM_PROPERTIES`.

```
docker run -e GO_AGENT_SYSTEM_PROPERTIES="-Dfoo=bar" showtimeanalytics/gocd-agent:17.4.0
```

If you want to specify memory limits directly, you can set up these envitonment variables with the values you prefer:

```bash
AGENT_MEM="512m"
AGNET_MAX_MEM="1024m"
```

## Under the hood

The GoCD server runs as the `go` user, the location of the various directories is:

| Directory           | Description                                                                      |
|---------------------|----------------------------------------------------------------------------------|
| `/data/config`      | the directory where the GoCD configuration is store                              |
| `/data/pipelines`   | the directory where the agent will run builds                                    |
| `/data/logs`        | the directory where GoCD logs will be written out to                             |
| `/opt/gocd`         | the home directory for the GoCD server                                           |

## Troubleshooting

### The GoCD agent does not connect to the server

- Check if the docker container is running `docker ps -a`
- Check the STDOUT to see if there is any output that indicates failures `docker logs CONTAINER_ID`
- Check the agent logs `docker exec -it CONTAINER_ID /bin/bash`, then run `less /data/logs/*.log` inside the container.

## Acknowledgments

- [GoCD official repository](https://github.com/gocd/docker-gocd-agent-alpine-3.5) (documentation is based on it)

