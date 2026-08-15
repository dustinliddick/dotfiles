# AWS CloudWatch Alarm Compliance Audit — us-east-1 (Production)

You are operating in the active AWS CLI profile for the `us-east-1` region.
Compare all **deployed CloudWatch alarms** for EC2 and RDS against the **standard production CloudFormation alarm stacks** located in the current working directory.

---

## Context
- Baseline: CloudFormation templates here define the approved **naming standards**, **metrics**, **dimensions**, and **thresholds**.
- Some active alarms in `us-east-1` show **INSUFFICIENT_DATA** or **naming drift**.
- The goal is to confirm that all alarms deployed in AWS align with the CloudFormation-defined standards and report all deviations.

---

## Validation Tasks
1. Enumerate all **CloudWatch alarms** in `us-east-1` across EC2 and RDS.
2. For each alarm, compare its configuration against the baseline CloudFormation template:
   - **AlarmName**
   - **MetricName**
   - **Namespace**
   - **Threshold**
   - **ComparisonOperator**
   - **EvaluationPeriods**
   - **Statistic**
   - **ActionsEnabled**
3. Identify and categorize:
   - ⚠️ **INSUFFICIENT_DATA** alarms
   - 🧩 **Drifted alarms** (names, thresholds, or metrics differ from template)
   - 🧱 **Manual alarms** (exist in AWS but not in CloudFormation)
   - ❌ **Missing alarms** (resources lacking alarms defined in baseline)
4. Ignore test or sandbox alarms (`*-test`, `*-sandbox`, `*-dev`).

---

## Output Format
Produce a structured compliance summary:

### ✅ Compliant Alarms
| Resource | Alarm Name | Metric | Status | Notes |
|-----------|-------------|---------|---------|--------|

### ⚠️ Drifted / Insufficient Data Alarms
| Resource | Alarm Name | Issue Type | Expected vs. Actual | Action Needed |

### 🧩 Orphaned / Manual Alarms
| Alarm Name | Region | Created By | Reason for Flag | Suggested Action |

### ❌ Missing Alarms
| Resource | Expected Alarm | Missing Metric | Suggested Action |

---

## 🔧 Recommendations & Remediation Plan
Provide a concise remediation plan suitable for a change control summary.
For each issue category, summarize what actions should be taken to restore compliance:

- **Recreate or update alarms** that differ from CloudFormation definitions.
- **Remove orphaned alarms** not managed by stacks.
- **Investigate insufficient data** alarms to confirm metric availability or missing data points.
- **Deploy missing alarms** for any EC2 or RDS instance lacking baseline coverage.
- Note any **CloudFormation template paramater files** that might require updating the baseline files or creation of client specific parameter files.

Conclude with an executive summary line such as:

> “Overall CloudWatch alarm compliance for `us-east-1` is X% aligned with production standards. Y alarms require remediation across Z resources.”
