#!/bin/sh


export BIN_DIR=`dirname $0`
export PROJECT_ROOT="${BIN_DIR}/.."
. "${PROJECT_ROOT}/services/backend/name.py"
export backend_app_name=${app_name}
export OFFLINE="${OFFLINE:=no}"
export REGGAE="no"


if [ "${1}" = "reggae" ]; then
  REGGAE="yes"
fi

cd "${PROJECT_ROOT}"
if [ "${REGGAE}" = "yes" ]; then
  backend_hostname=$(sudo cbsd jexec user=devel "jname=${backend_app_name}" hostname)
  make offline=${OFFLINE} SYSPKG=${SYSPKG} -C services/backend init
  sudo tmux new-session -s "${backend_app_name}" -d "make offline=${OFFLINE} SYSPKG=${SYSPKG} -C services/backend devel"
  sudo tmux split-window -h -p 50 -t 0 "make OFFLINE=${OFFLINE} BACKEND_URL=http://${backend_hostname}:5000 -C services/frontend devel"
  sudo tmux a -t "${backend_app_name}"

else
  backend_hostname='localhost'
  "${BIN_DIR}/download_repos.sh"
  env OFFLINE=${OFFLINE} SYSPKG=${SYSPKG} "${PROJECT_ROOT}/services/backend/bin/init.sh"
  tmux new-session -s "${backend_app_name}" -d "env OFFLINE=${OFFLINE} SYSPKG=${SYSPKG} ${PROJECT_ROOT}/services/backend/bin/devel.sh"
  tmux split-window -h -p 50 -t 0 "env OFFLINE=${OFFLINE} BACKEND_URL=http://${backend_hostname}:5000 ${PROJECT_ROOT}/services/frontend/bin/devel.sh"
  tmux a -t "${backend_app_name}"
fi
