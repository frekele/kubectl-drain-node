# kubectl-drain-node

**AWS EC2 has 3 ways to terminate an instance**
 - [Spot instances Termination](https://aws.amazon.com/pt/blogs/aws/new-ec2-spot-instance-termination-notices/): The Termination Notice is accessible to code running on the instance via the instance’s metadata at http://169.254.169.254/latest/meta-data/spot/termination-time 

 - [Auto Scaling Termination](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroupLifecycle.html): The EC2 instances in an Auto Scaling group have a path, or lifecycle, that differs from that of other EC2 instances

- User request Termination: When the user terminates an instance manually.


My script 'a1-kubectl-drain-node' launches a listener in backgroud that ends the instance in advance when she is marked as spot termination through the url  http://169.254.169.254/latest/meta-data/spot/termination-time .

If it is not terminated in advance, it can also be terminated when the instance is already in the process of closing, so it runs the script at level 0 (/etc/rc0.d/K01a1-kubectl-drain-node).


# Install kubectl-drain-node
```
curl https://raw.githubusercontent.com/frekele/kubectl-drain-node/master/kubectl-drain-node.sh -o /etc/init.d/a1-kubectl-drain-node && \
chmod 775 /etc/init.d/a1-kubectl-drain-node && \
update-rc.d a1-kubectl-drain-node defaults && \
update-rc.d a1-kubectl-drain-node enable && \
service a1-kubectl-drain-node start
```


# pre requirements

### Install kubectl:
```
//(your kubernetes version);
K8S_VERSION=v1.11.1
//or latest release.
K8S_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl -o /tmp/kubectl && \
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl.md5 -o /tmp/kubectl.md5 && \
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl.sha1 -o /tmp/kubectl.sha1 && \
echo "$(cat kubectl.md5) kubectl" | md5sum -c && \
echo "$(cat kubectl.sha1) kubectl" | sha1sum -c && \
mv /tmp/kubectl /usr/local/bin/kubectl && \
rm -f /tmp/kubectl.md5 && \
rm -f /tmp/kubectl.sha1 && \
chmod +x /usr/local/bin/kubectl
```
