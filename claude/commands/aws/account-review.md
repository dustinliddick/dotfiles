# AWS Account Survey (US Regions) — Network, Load Balancers & EC2

Evaluate the aws account that is loaded on my command line. I will be in the proper aws account. I will be in that accounts default region, however, I want the entire us regions covered for this audit/evaluation/survey. This is to onboard a new engineer. Focus only on US commercial regions and inventory VPCs, subnets, security groups, load balancers (ALB/NLB/CLB), target groups, and EC2 instances registered to those target groups. Default regions: us-east-1, us-east-2, us-west-1, us-west-2.  ￼

⸻

Instructions

1. Scope & Preconditions
	•	Operate read-only; no mutations.
	•	Use provided regions list or default to the four US regions above. Exclude GovCloud/ISO.
	•	Validate each region is enabled before querying.
	•	Handle pagination and throttling across all describe-* calls.

2. VPC & Networking Inventory
	•	DescribeVpcs: List all VPCs (VpcId, Name tag, CIDR, IsDefault).
	•	For each VPC:
	•	DescribeSubnets: SubnetId, AZ, CIDR, tags.
	•	DescribeSecurityGroups: Summarize rules (proto/port/source).
	•	DescribeVpcEndpoints: Service, type, state, route table associations.
	•	Identify unused or redundant VPCs, subnets, or SGs as decom candidates.

3. Load Balancers (ALB/NLB/GLB)
	•	elbv2:DescribeLoadBalancers: Capture type, scheme, VPC, subnets/AZs.
	•	elbv2:DescribeListeners + DescribeLoadBalancerAttributes.
	•	elbv2:DescribeTargetGroups: Protocol:port, targetType, health check.
	•	elbv2:DescribeTargetHealth: Identify targets and health.
	•	Flag idle LBs/TGs with no traffic or failing health checks.

4. Classic ELB (CLB)
	•	elb:DescribeLoadBalancers (2012-06-01): List CLBs, listeners, registered instances.
	•	Note if legacy ELBs remain → decom candidate.

5. EC2 Instances Behind LBs
	•	DescribeInstances for registered targets.
	•	Enrich with tags (Name/ASG), instance type, state, IPs, subnet, SGs, AZ.
	•	Map instance ↔ TG/LB membership + target health.
	•	Highlight instances not in ASGs, unhealthy, or with low utilization.

6. Per-Region Outputs
	•	Markdown Summary
	•	Regional counts: VPCs, subnets, SGs, LBs (by type), TGs, EC2s.
	•	Tables for VPCs, Load Balancers, Target Groups, EC2 behind LBs.
	•	JSON Artifact
	•	Emit complete inventory, keyed by region: vpcs, loadBalancers[...targetGroups[...targets]], and ec2.

7. Quality & Safety
	•	Resolve cross-refs deterministically by ARN/Id.
	•	Note unattached/empty resources (decom candidates).
	•	Respect API limits; retries/sleeps for throttling.
	•	Do not enumerate non-US regions unless explicitly requested.

8. Required APIs
	•	EC2/VPC: DescribeVpcs, DescribeSubnets, DescribeSecurityGroups, DescribeVpcEndpoints, DescribeInstances.
	•	ELBv2: DescribeLoadBalancers, DescribeListeners, DescribeLoadBalancerAttributes, DescribeTargetGroups, DescribeTargetHealth.
	•	Classic ELB: DescribeLoadBalancers (2012-06-01).

9. Deliverables
	•	US-Region-Network-&-LB-Survey.md (per-region human-readable report).
	•	us-account-inventory.json (machine-readable).
	•	Observations: Identify risks, efficiency gains (e.g., consolidating SGs, right-sizing EC2s), and explicit decom candidates.

⸻

Narrative Bits
	•	Summary: Provide a plain-language overview of network and compute footprint.
	•	Risks: Call out security group risks (wide open ports), failing/unhealthy targets, legacy CLBs, orphaned resources.
	•	Actions: Recommend remediation (tighten SGs, decom idle resources, modernize CLBs to ALBs, consolidate VPCs).

Save final report as aws-account-survey.md.

⸻

Write the short narrative bits (Summary, Risks, Actions). Save as aws-account-survey.md

