FROM showtimeanalytics/alpine-java:8u131b11_server-jre

MAINTAINER Alberto Gregoris <alberto@showtimeanalytics.com>

LABEL gocd.version="17.4.0" \
      description="GoCD agent based on AlpineLinux" \
      maintainer="Alberto Gregoris <alberto@showtimeanalytics.com>" \
      gocd.full.version="17.4.0-4892" \
      gocd.git.sha="ab17b819e73477a47401744fa64f64fda55c26e8"


ARG DOCKER_VERSION=17.03.1-ce
ARG DOCKER_GROUP=docker
ARG DOCKER_GID=10000

ENV GO_FULL_VERSION=17.4.0-4892 \
    AGENT_DIR=/opt/gocd \
    AGENT_WORK_DIR=/gocd-data
ENV CONFIG_DIR=${AGENT_WORK_DIR}/config \
    LOGS_DIR=${AGENT_WORK_DIR}/logs
ENV STDOUT_LOG_FILE=${LOGS_DIR}/go-agent-bootstrapper.out.log \
    LANG=en_US.utf8 \
    USER=gocd \
    GROUP=gocd \
    UID=10014 \
    GID=10014

RUN set -ex \
 && apk --update add fping curl tar bash git make openssh-client su-exec jq \
 && curl -ksSL https://download.gocd.io/binaries/${GO_FULL_VERSION}/generic/go-agent-${GO_FULL_VERSION}.zip -o /tmp/go-agent.zip \
 && unzip /tmp/go-agent.zip -d /tmp \
 && mkdir -p ${AGENT_DIR} ${AGENT_WORK_DIR} ${CONFIG_DIR} ${LOGS_DIR} \
 && mv /tmp/go-agent-*/* ${AGENT_DIR}/ \
 && mv ${AGENT_DIR}/config/* ${CONFIG_DIR} \
 && touch ${STDOUT_LOG_FILE} \
 && curl -fsSL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz -o /tmp/docker-${DOCKER_VERSION}.tgz \
 && tar --strip-components=1 -xvzf /tmp/docker-${DOCKER_VERSION}.tgz -C /usr/local/bin \
 && addgroup -g ${DOCKER_GID} ${DOCKER_GROUP} \
 && addgroup -g ${GID} ${GROUP} \
 && adduser -g "${USER} user" -D -h ${AGENT_DIR} -G ${GROUP} -s /sbin/nologin -u ${UID} ${USER} \
 && adduser ${USER} ${DOCKER_GROUP} \
 && chown -R ${USER}:${GROUP} ${AGENT_DIR} ${AGENT_WORK_DIR} \
 && rm -rf /tmp/* \
           /var/cache/apk/* \
           ${AGENT_DIR}/config

VOLUME ${AGENT_WORK_DIR}

WORKDIR ${AGENT_WORK_DIR}

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
