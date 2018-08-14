# kubectl drain node - AWS EC2 Spot - Debian

**AWS EC2 has 3 ways to terminate an instance**
 - [Spot instances Termination](https://aws.amazon.com/pt/blogs/aws/new-ec2-spot-instance-termination-notices/): The Termination Notice is accessible to code running on the instance via the instance’s metadata at http://169.254.169.254/latest/meta-data/spot/termination-time 

 - [Auto Scaling Termination](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroupLifecycle.html): The EC2 instances in an Auto Scaling group have a path, or lifecycle, that differs from that of other EC2 instances

- User request Termination: When the user terminates an instance manually.


This script 'a1-kubectl-drain-node' launches a listener in backgroud that ends the instance in advance when she is marked as spot termination through the url  http://169.254.169.254/latest/meta-data/spot/termination-time .

If it is not terminated in advance, it can also be terminated when the instance is already in the process of shutdown, so it runs the script at level 0 (/etc/rc0.d/K01a1-kubectl-drain-node).

[To understand the system runlevel, see here](https://debian-administration.org/article/212/An_introduction_to_run-levels).

# Pre-requirements:

### kubectl:
```
K8S_VERSION=v1.11.1 //(your kubernetes version).
K8S_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) //(or latest release).

curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl -o /tmp/kubectl && \
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl.md5 -o /tmp/kubectl.md5 && \
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl.sha1 -o /tmp/kubectl.sha1 && \
echo "$(cat /tmp/kubectl.md5) /tmp/kubectl" | md5sum -c && \
echo "$(cat /tmp/kubectl.sha1) /tmp/kubectl" | sha1sum -c && \
mv /tmp/kubectl /usr/local/bin/kubectl && \
rm -f /tmp/kubectl.md5 && \
rm -f /tmp/kubectl.sha1 && \
chmod +x /usr/local/bin/kubectl
```

### kubeconfig:
```
mkdir -p /root/.kube && \
cp 'your-kubernetes-config' /root/.kube/aws-cloud && \
chmod 755 /root/.kube/aws-cloud
```

It is recommended to install this script when launching the instance with cloud-init.

# Install kubectl-drain-node
```
KDN_VERSION=v1.0.0
curl -L https://github.com/frekele/kubectl-drain-node/releases/download/${KDN_VERSION}/kubectl-drain-node.sh -o /tmp/kubectl-drain-node.sh && \
curl -L https://github.com/frekele/kubectl-drain-node/releases/download/${KDN_VERSION}/kubectl-drain-node.sh.md5 -o /tmp/kubectl-drain-node.sh.md5 && \
curl -L https://github.com/frekele/kubectl-drain-node/releases/download/${KDN_VERSION}/kubectl-drain-node.sh.sha1 -o /tmp/kubectl-drain-node.sh.sha1 && \
echo "$(cat /tmp/kubectl-drain-node.sh.md5) /tmp/kubectl-drain-node.sh" | md5sum -c && \
echo "$(cat /tmp/kubectl-drain-node.sh.sha1) /tmp/kubectl-drain-node.sh" | sha1sum -c && \
mv /tmp/kubectl-drain-node.sh /etc/init.d/a1-kubectl-drain-node && \
chmod 775 /etc/init.d/a1-kubectl-drain-node && \
update-rc.d a1-kubectl-drain-node defaults && \
update-rc.d a1-kubectl-drain-node enable && \
service a1-kubectl-drain-node start
```
