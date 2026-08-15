# Comprehensive AWS Patch Management review
You are a senior AWS patch management auditor. Work against the AWS profile that is already loaded in my shell (respect AWS_PROFILE, AWS_DEFAULT_REGION, and any assumed role). Do NOT perform destructive actions; gather READ-ONLY facts and produce a clear report I can hand to leadership and stakeholders.

## Objective
Conduct a comprehensive review of patch management policies and posture for BOTH EC2 and RDS across the currently loaded AWS profile. Gather all necessary information systematically and output: (1) an executive summary, (2) detailed findings, (3) gaps/risks, and (4) remediation recommendations with specific, actionable steps.

## Scope & Assumptions
- Use the CURRENT AWS profile & creds in my environment. Do not ask me to reconfigure.
- Enumerate only regions that contain running resources (to save time) unless I specify otherwise.
- Prefer AWS CLI commands (bash) with JMESPath queries. Where the CLI can’t answer directly, provide equivalent boto3 snippets.
- If you cannot execute commands, generate the exact commands/scripts I should run locally and then show how to parse/compile the results into the final report.

## Deliverables (Markdown)
1) **Executive Summary (bulleted, ≤10 bullets)** — overall EC2 & RDS patch posture; % coverage; top risks; quick wins.
2) **EC2 Patch Posture**
   - Inventory table of SSM-managed vs non-managed EC2 instances (by region), including:
     InstanceId, Name, OS (Linux/Windows + distro/version), SSM Agent version, SSM PingStatus, PatchGroup tag, MaintenanceWindow assigned?, Last patch operation & timestamp, Missing/Failed patch counts.
   - Patch Baselines (default & custom) per OS family; which PatchGroup(s) map to which baselines; approval rules; auto-approve delays; include exceptions/overrides.
   - State Manager associations for **AWS-RunPatchBaseline** (scan and install); cadence and compliance coverage.
   - Maintenance Windows used for patching (targets, schedule, tasks).
   - AWS Config/Compliance signals (e.g., EC2-PATCH-COMPLIANCE rule) if present.
3) **RDS Patch Posture**
   - Inventory of RDS **instances** and **clusters** (Aurora & non-Aurora) by region with:
     DBInstanceIdentifier/DBClusterIdentifier, Engine, Current EngineVersion, AutoMinorVersionUpgrade flag (instance-level), PreferredMaintenanceWindow, PendingMaintenanceActions, MultiAZ, InstanceClass.
   - For each engine family, show the latest available minor version and whether each DB is at/behind that minor.
   - Identify any pending maintenance (engine minor upgrades, system updates) and windows.
4) **Gaps & Risks**
   - Unmanaged EC2 (not in SSM), stale SSM agents, missing PatchGroup tags, missing/unused baselines, no maintenance windows, low compliance, RDS instances without AutoMinorVersionUpgrade, clusters behind latest recommended minor.
5) **Recommendations**
   - Concrete actions with CLI snippets: enroll unmanaged EC2 into SSM, set/standardize PatchGroup tags, create/attach custom baselines, schedule State Manager associations, define Maintenance Windows, enable/verify AutoMinorVersionUpgrade for RDS, plan engine upgrades, enable AWS Config rules for patch compliance.
6) **Appendix A – Commands Used**
   - Provide all commands you propose in copy-pastable blocks, grouped by purpose.

## Method (generate these commands; if you can run them, include sanitized output samples)
### 0) Identity & Regions
- Who am I?
  aws sts get-caller-identity
- Regions with live resources (limit scope):
  aws ec2 describe-regions --all-regions --query 'Regions[].RegionName' --output text
  For each region, check presence:
  - EC2: aws ec2 describe-instances --region <r> --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text
  - RDS: aws rds describe-db-instances --region <r> --query 'DBInstances[].DBInstanceIdentifier' --output text
  Only include regions that return resources.

### 1) EC2 + SSM Inventory & Compliance
- Managed instances:
  aws ssm describe-instance-information --region <r> \
    --query 'InstanceInformationList[].{InstanceId:InstanceId,PlatformName:PlatformName,PlatformVersion:PlatformVersion,AgentVersion:AgentVersion,PingStatus:PingStatus,IPAddress:IPAddress}'
- EC2 metadata & PatchGroup tag:
  aws ec2 describe-instances --region <r> \
    --filters Name=instance-state-name,Values=running \
    --query 'Reservations[].Instances[].{InstanceId:InstanceId,Name:Tags[?Key==`Name`]|[0].Value,PatchGroup:Tags[?Key==`PatchGroup`]|[0].Value,Platform:PlatformDetails}'
- Patch compliance:
  aws ssm describe-instance-patch-states --region <r> --instance-ids $(INSTANCE_IDS) \
    --query 'InstancePatchStates[].{InstanceId:InstanceId,Missing:MissingCount,Installed:InstalledCount,Failed:FailedCount,Operation:Operation,Ended:OperationEndTime}'
- Associations (AWS-RunPatchBaseline):
  aws ssm list-associations --region <r> \
    --association-filter-list key=Name,value=AWS-RunPatchBaseline
  For each AssociationId:
  aws ssm describe-association --region <r> --association-id <id> \
    --query '{Name:AssociationDescription.Name,Schedule:AssociationDescription.ScheduleExpression,Targets:AssociationDescription.Targets}'
- Maintenance Windows:
  aws ssm describe-maintenance-windows --region <r> \
    --query 'WindowIdentities[].{Id:WindowId,Name:Name,Schedule:Schedule}'
  For each WindowId:
  aws ssm describe-maintenance-window-targets --region <r> --window-id <id>
  aws ssm describe-maintenance-window-tasks --region <r> --window-id <id>
- Baselines & PatchGroups:
  aws ssm describe-patch-groups --region <r> \
    --query 'Mappings[].{PatchGroup:PatchGroup,BaselineId:BaselineIdentity.BaselineId}'
  For each BaselineId:
  aws ssm get-patch-baseline --region <r> --baseline-id <id> \
    --query '{Name:Name,OperatingSystem:OperatingSystem,ApprovalRules:ApprovalRules,GlobalFilters:GlobalFilters,Sources:Sources}'
- Defaults per OS (spot-check):
  for os in AMAZON_LINUX AMAZON_LINUX_2 AMAZON_LINUX_2023 UBUNTU DEBIAN CENTOS REDHAT SUSE WINDOWS; do
    aws ssm get-default-patch-baseline --region <r> --operating-system $os || true
  done
- AWS Config rule (if used):
  aws configservice describe-config-rules --region <r> \
    --query 'ConfigRules[?ConfigRuleName==`EC2-PATCH-COMPLIANCE` || contains(ConfigRuleName, `PATCH`)].ConfigRuleName'

### 2) RDS Posture
- Instances:
  aws rds describe-db-instances --region <r> \
    --query 'DBInstances[].{Id:DBInstanceIdentifier,Engine:Engine,Version:EngineVersion,AutoMinor:AutoMinorVersionUpgrade,MaintWindow:PreferredMaintenanceWindow,Pending:PendingModifiedValues,MultiAZ:MultiAZ,Class:DBInstanceClass,Cluster:DBClusterIdentifier}'
- Clusters (Aurora):
  aws rds describe-db-clusters --region <r> \
    --query 'DBClusters[].{Id:DBClusterIdentifier,Engine:Engine,Version:EngineVersion,MaintWindow:PreferredMaintenanceWindow,Pending:PendingModifiedValues}'
- Pending maintenance:
  aws rds describe-pending-maintenance-actions --region <r> \
    --query 'PendingMaintenanceActions[].{Resource:ResourceIdentifier,Actions:PendingMaintenanceActionDetails}'
- Latest minor versions per engine (map current to latest minor):
  # For each unique Engine from the inventory, query engine versions:
  aws rds describe-db-engine-versions --region <r> --engine <engine> \
    --query 'DBEngineVersions[].EngineVersion'
  (Choose the highest minor within the same major version as each instance/cluster.)

### 3) Coverage & Compliance Calculations
- % of EC2 running instances that are SSM-managed.
- For SSM-managed: % compliant (MissingCount == 0 and FailedCount == 0) in last scan/install.
- % of EC2 with PatchGroup tag and mapped to a baseline.
- % of managed instances attached to a Maintenance Window and Association for patching.
- % of RDS instances with AutoMinorVersionUpgrade=true and with no pending maintenance.
- Count of RDS behind latest minor within major.

### 4) Findings & Recommendations
- List unmanaged EC2 and what to do (attach IAM role/SSM agent, patch group tag).
- Standardize baselines (per OS), auto-approve policies, and test rings.
- Ensure recurring scan + install associations and maintenance windows per environment.
- For RDS: enable AutoMinorVersionUpgrade where appropriate; plan minor upgrades; align maintenance windows with app SLAs.

## Output Formatting
- Use concise Markdown tables for inventories and metrics. Keep very wide columns to a minimum.
- At the end, include **Appendix A – Commands Used** with all commands grouped by section and shell-ready.
- If any information cannot be collected automatically, clearly mark it as “Manual Check” and provide exact steps.

## Guardrails
- READ-ONLY only; no modifications.
- If something is ambiguous (e.g., region list), make a reasonable default choice and state it. Ask ONE clarifying question only if absolutely necessary.
- Be explicit about dates/times (include timezone) on any “last operation” fields.
