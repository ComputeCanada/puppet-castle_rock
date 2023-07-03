#!/bin/bash

if [ -z $1 ]; then
    echo "Usage: $0 username"
    exit
fi

USERNAME=$1

if ! id $USERNAME &> /dev/null; then
    echo "Cannot find username \"$USERNAME\"";
    exit
fi

USER_HOME=$(getent passwd $USERNAME | cut -d: -f6)

mkdir ${USER_HOME}
rsync -opg -r -u --chown=$USERNAME:$USERNAME --chmod=D700,F700 /etc/skel/ ${USER_HOME}
restorecon -F -R ${USER_HOME}

# USER_SCRATCH="/scratch/${USERNAME}"

# mkdir -p ${USER_SCRATCH}
# ln -sfT ${USER_SCRATCH} "${USER_HOME}/scratch"
# chown -h ${USERNAME}:${USERNAME} "${USER_HOME}/scratch"
# chown -h ${USERNAME}:${USERNAME} ${USER_SCRATCH}
# chmod 750 ${USER_SCRATCH}
# restorecon -F -R ${USER_SCRATCH}

for GROUP in $(id -Gn $USERNAME); do
    if [[ "$GROUP" =~ ^(ctb|def|rpp|rrg)-[a-z0-9_-]*$ ]]; then
        GID=$(getent group $GROUP | cut -d: -f3)
        PROJECT_GID="/project/$GID"
        PROJECT_GROUP="/project/$GROUP"
        mkdir -p ${PROJECT_GID}
        chown root:"$GROUP" ${PROJECT_GID}
        chmod 2770 ${PROJECT_GID}
        ln -sfT "/project/$GID" ${PROJECT_GROUP}
        restorecon -F -R ${PROJECT_GID} ${PROJECT_GROUP}
        mkdir -p "${USER_HOME}/projects"
        ln -sfT "/project/${GROUP}" "${USER_HOME}/projects/${GROUP}"
    fi
done
