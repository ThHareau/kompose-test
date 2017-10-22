#/bin/bash
set -e

if [ "$#" -lt 1 ]; then
	echo "Illegal number of parameters"
	echo "usage: ./kompose_install.sh <MANAGER>"
	exit 1
fi

MANAGER=$1

scp -rp docker-stack.yml $MANAGER:/tmp
if [ "$CLUSTER_TYPE" == "swarm" ]; then
  ssh $MANAGER docker stack deploy --compose-file /tmp/docker-stack.yml vote
else
  echo "converting compose file"
  ssh $MANAGER '
    cd /tmp
    sed -i 's/on-failure/always/g' docker-stack.yml
    mkdir kompose-stack-manifest
    kompose convert -o kompose-stack-manifest -f docker-stack.yml
    cd kompose-stack-manifest
    rm db-data-persistentvolumeclaim.yaml
    sed -i  "s/persistentVolumeClaim:/emptyDir: {}/g" db-deployment.yaml
    sed -i "/claimName/d" db-deployment.yaml
    cat > visualizer-data-pv-volume.yaml << EOF                
kind: PersistentVolume
apiVersion: v1
metadata:
  name: visualizer-data-pv-volume
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/var/run/docker.sock"
EOF
  '

  echo "launching files"
  ssh $MANAGER kubectl create -f /tmp/kompose-stack-manifest

fi
