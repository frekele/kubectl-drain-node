# kubectl-drain-node

**AWS EC2 has 3 ways to terminate an instance**
 - [Spot instances Termination](https://aws.amazon.com/pt/blogs/aws/new-ec2-spot-instance-termination-notices/): The Termination Notice is accessible to code running on the instance via the instance’s metadata at http://169.254.169.254/latest/meta-data/spot/termination-time 

 - [Auto Scaling Termination](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroupLifecycle.html): The EC2 instances in an Auto Scaling group have a path, or lifecycle, that differs from that of other EC2 instances

- User request Termination: When the user terminates an instance manually.


My script 'a1-kubectl-drain-node' launches a listener in backgroud that ends the instance in advance when she is marked as spot termination through the url  http://169.254.169.254/latest/meta-data/spot/termination-time .

If it is not terminated in advance, it can also be terminated when the instance is already in the process of closing, so it runs the script at level 0 (/etc/rc0.d/K01a1-kubectl-drain-node).
