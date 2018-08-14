#!/bin/bash
### BEGIN INIT INFO
# Provides:           a1-kubectl-drain-node
# Required-Start:     $syslog $network $remote_fs
# Required-Stop:      $syslog $network $remote_fs
# Should-Start:       docker
# Should-Stop:        docker
# Default-Start:      2 3 4 5
# Default-Stop:       0
# Short-Description:  Kubernetes Drain Node before instance terminate.
# Description:
#  Kubernetes Drain Node before instance terminate, Run kubectl command.
#  Author: frekele
### END INIT INFO

## For configuration:
## Add file 'a1-kubectl-drain-node' into /etc/init.d/
## systemctl daemon-reload
## update-rc.d a1-kubectl-drain-node defaults
## update-rc.d a1-kubectl-drain-node enable
## service a1-kubectl-drain-node start
##
## Others commands:
## update-rc.d a1-kubectl-drain-node disable
## update-rc.d a1-kubectl-drain-node remove
## service a1-kubectl-drain-node start|stop|status

set -e

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

# Get lsb functions
. /lib/lsb/init-functions

function spotTerminationBackgroundListener(){
    echo "spotTerminationBackgroundListener Started."
    #Sleep 5 minutes.
    sleep 300
    
    HOSTNAME_FQDN=$(hostname --fqdn)
    KUBE_CONFIG=/root/.kube/aws-cloud
    KDRAIN_LOGFILE=/var/log/a1-kubectl-drain-node.log
    
    kubectl get node ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
    while true
        do
            if [ -z $(curl -Is http://169.254.169.254/latest/meta-data/spot/termination-time | head -1 | grep 404 | cut -d \  -f 2) ]
                then
                    echo "Spot Instance marked for termination!"
                    kubectl get node ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
                    kubectl drain ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
                    kubectl drain ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
                    kubectl delete node ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
                    break
                else
                    #echo "Spot instance not yet marked for termination."
                    sleep 5
            fi
        done
    echo "spotTerminationBackgroundListener Stopped."
}

HOSTNAME_FQDN=$(hostname --fqdn)
KUBE_CONFIG=/root/.kube/aws-cloud
KDRAIN_LOGFILE=/var/log/a1-kubectl-drain-node.log

case "$1" in
        start)
                echo "Starting a1-kubectl-drain-node" >> "$KDRAIN_LOGFILE" 2>&1
                touch "$KDRAIN_LOGFILE"
                chown root:root "$KDRAIN_LOGFILE"
                export -f spotTerminationBackgroundListener
                nohup bash -c spotTerminationBackgroundListener >> "$KDRAIN_LOGFILE" 2>&1 &
                echo "Started a1-kubectl-drain-node" >> "$KDRAIN_LOGFILE" 2>&1
                ;;

        stop)
                echo "Stoping a1-kubectl-drain-node" >> "$KDRAIN_LOGFILE" 2>&1
                kubectl get node ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
                kubectl drain ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
                kubectl drain ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
                kubectl delete node ${HOSTNAME_FQDN} --kubeconfig=${KUBE_CONFIG} --insecure-skip-tls-verify=true >> "$KDRAIN_LOGFILE" 2>&1 | true
                echo "Stopped a1-kubectl-drain-node" >> "$KDRAIN_LOGFILE" 2>&1
                ;;

        status)
                echo "Status a1-kubectl-drain-node" >> "$KDRAIN_LOGFILE" 2>&1
                ;;

        *)
                echo "Usage: service a1-kubectl-drain-node {start|stop|status}" >&2
                exit 1
                ;;
esac
