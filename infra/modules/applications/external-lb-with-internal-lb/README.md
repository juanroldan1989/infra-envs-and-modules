# External Load Balancer with Internal Load Balancer

Experiment needs more details and to be refined

Current issue:

- Targets shown as "Unhealthy" for Internal Load Balancer
- Same targets are shown as "Healthy" for External Load Balancer

### External Load Balancer with Internal Load Balancer

![Screenshot 2024-08-16 at 21 16 37](https://github.com/user-attachments/assets/437e8eb7-a7bc-4c84-aa86-3f9af7da5529)

### Response to similar issue

https://nav7neeet.medium.com/load-balance-traffic-to-private-ec2-instances-cb07058549fd

Solution to EC2 instances (inside private subnets) being unhealthy:

```
The web server might not be installed in the EC2 instance. This may be because EC2 machines are launched in the private subnet and don’t have internet access. So when we try to install the web server by putting the installation command in the EC2 user data section it fails.

Resolution: To resolve this create a NAT gateway in the public subnet and modify the routing table of the private subnet to point to the NAT gateway. This is the only step where a NAT gateway is required. It can be removed once the HTTP server is installed on EC2 instances.
```

## Load Balancer - Target Types

`Instance` vs. `IP`

Really good explanation with graphs:
https://aws.github.io/aws-eks-best-practices/networking/loadbalancing/loadbalancing/#register-pods-as-targets-using-ip-target-type

