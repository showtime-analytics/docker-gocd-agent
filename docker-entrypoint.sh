#!/bin/bash

shopt -s extglob

setup_autoregister_properties_file_for_normal_agent() {
  echo "Setting up autoregister properties in $1" >> ${STDOUT_LOG_FILE} 2>&1
  echo "agent.auto.register.key=${AGENT_AUTO_REGISTER_KEY}" > $1
  echo "agent.auto.register.resources=${AGENT_AUTO_REGISTER_RESOURCES}" >> $1
  echo "agent.auto.register.environments=${AGENT_AUTO_REGISTER_ENVIRONMENTS}" >> $1
  echo "agent.auto.register.hostname=${HOSTNAME}" >> $1

  # unset variables, so we don't pollute and leak sensitive stuff to the agent process...
  unset AGENT_AUTO_REGISTER_KEY AGENT_AUTO_REGISTER_RESOURCES AGENT_AUTO_REGISTER_ENVIRONMENTS

  chown ${USER}:${GROUP} $1
}

clean_previous_agent() {
  rm -f ${AGENT_WORK_DIR}/.agent-bootstrapper.running
  rm -f +([a-z]|[0-9]|-)agent-launcher.jar
}

setup_autoregister_properties_file_for_normal_agent "${AGENT_WORK_DIR}/config/autoregister.properties"

clean_previous_agent

su-exec ${USER} /opt/gocd/agent.sh
