# Performance Test Results Analysis

Analyze k6 + Playwright performance test results and produce technical analysis plus stakeholder reports.

## Instructions

This skill operates in two phases, producing two distinct deliverables from performance test data.

---

## Step 0: Gather Test Artifacts

The user will typically paste the **console output from their test suite run**. This output contains:
- Suite directory path (e.g., `reports/suite-20260318-195131/`)
- Data collection summary
- SSO metrics summary
- File manifest

**From the pasted output, extract:**
1. **Suite Directory**: Look for paths like `/Users/.../reports/suite-YYYYMMDD-HHMMSS/`
2. **Time Range**: The test execution window
3. **Quick SSO Summary**: Login attempts, success/failure counts

**Then read these files from the suite directory:**

### Required Files
```
<suite-dir>/
├── SUITE_REPORT.txt                    # Executive summary of the run
├── metadata.json                       # Suite configuration
├── analysis/
│   ├── summary.json                    # Comprehensive metrics
│   ├── sso_metrics.json               # SSO performance & timing breakdown
│   └── all_errors_summary.txt         # Aggregated error counts
├── infrastructure/
│   ├── summary.json                   # Infrastructure metrics summary
│   ├── rds_connections.json           # Database connections over time
│   ├── rds_cpu.json                   # Database CPU utilization
│   ├── alb_request_count.json         # ALB request metrics (or alb-request-count.json)
│   ├── alb_response_time.json         # ALB response time (or alb-response-time.json)
│   └── alb_5xx_errors.json            # ALB 5xx errors (or alb-5xx-errors.json)
├── logs/
│   ├── ecs/tasks.log                  # ECS task execution logs
│   └── application/
│       └── rds_issues.log             # Slow queries and errors
├── faculty/                           # Faculty phase results (task-*.json files)
├── learner/                           # Learner phase results (task-*.json files)
└── reset/                             # Reset phase results
```

### Also Read
- **TEST_PLAN.md**: Located at project root (e.g., `projects/asa-saudi-mock-exam/TEST_PLAN.md`)
  - Contains pass/fail thresholds
  - Contains validation mandates
  - Contains protocol definitions

**Ask the user only if the suite directory cannot be extracted from their paste.**

---

# PHASE 1: Technical Analysis Report

**Role:** You are acting as a **Senior Performance Engineer / Site Reliability Engineer** reviewing load and workflow test results generated using **k6 and Playwright**.

**Audience:** Engineers and developers who need technical depth.

**Output File:** `<suite-dir>/TECHNICAL_ANALYSIS.md`

**Critical Requirement:** Avoid generic summaries. Provide **technical reasoning and evidence-backed conclusions.** Never say "The system slowed down under load." Instead explain **why the system slowed down and what component caused it.**

---

## Phase 1 Structure

### 1. Purpose of the Tests

Explain:
- What the test suite was designed to validate (reference TEST_PLAN.md mandates)
- Why both **k6 and Playwright** were used
- What user workflows or application behavior were being simulated
- The expected system behavior under load

Explain the difference between:
- **API/HTTP load testing (k6)** - backend load generation, request latency measurement
- **Browser-level workflow simulation (Playwright)** - real user interaction, UI validation, SSO flow

---

### 2. Test Architecture

Describe the architecture involved in the test.

Application components (extract from infrastructure metrics):
- Web servers (Apache)
- Load balancers (ALB)
- Application services (PHP-FPM, Totara/Moodle)
- Databases (RDS PostgreSQL)
- Caches (if applicable)
- Authentication services (Azure B2C → ASA SAML → LMS)

Explain:
- How Playwright interacts with the system (browser-based, ECS tasks)
- How k6 generates load (if used)
- How both tools combine to simulate real usage patterns

---

### 3. Test Configuration

#### Playwright Configuration (from metadata.json)

Include analysis of:
- Number of ECS tasks launched
- Concurrency model (tasks per phase)
- User workflows simulated (faculty provisioning, learner quiz flow)
- Login/authentication flows (SSO via Azure B2C)

#### Load Profile (from suite structure)

- Reset phase: What it did
- Faculty phase: Number of faculty, actions performed
- Learner phase: Number of learners, concurrent users, quiz workflow

Explain what real-world user behavior the combined tests represent.

---

### 4. Metrics Observed

#### Playwright/Browser Metrics (from analysis/summary.json, task-*.json)

Analyze:
- Page load times
- SSO flow timing (Azure B2C → SAML → LMS)
- Quiz completion times
- UI interaction latency
- Failures or retries

Explain what these metrics indicate about **front-end performance and application responsiveness.**

#### SSO Metrics (from analysis/sso_metrics.json)

Analyze:
- Total login attempts
- Success/failure rates
- Failures by domain (Azure B2C vs ASA SAML vs LMS)
- SSO timing breakdown per phase

Explain what these metrics indicate about **authentication bottlenecks**.

#### Infrastructure Metrics (from infrastructure/*.json)

Analyze:
- **RDS Database:**
  - CPU utilization (rds_cpu.json)
  - Database connections (rds_connections.json)
  - Read/write latency
  - IOPS
- **ALB:**
  - Request count (alb_request_count.json)
  - Response time (alb_response_time.json)
  - 5xx errors (alb_5xx_errors.json)
- **ECS:**
  - Task CPU/memory utilization

Explain what these metrics indicate about **backend system behavior under load.**

---

### 5. Test Execution Analysis

Describe how the system behaved during the test:
- When each phase began and ended
- When performance degradation started (if any)
- Whether latency increased gradually or sharply
- Whether errors appeared and when
- Whether the system stabilized or cascaded

Reference specific timestamps from the logs.

Explain the **relationship between the load profile and system response.**

---

### 6. Bottleneck Identification

Identify and explain performance bottlenecks.

Possible bottleneck categories:
- Application logic inefficiencies
- Database query performance (check rds_issues.log for slow queries)
- SSO/authentication bottlenecks (check sso_metrics.json)
- Session management issues
- Frontend rendering delays
- Third-party service issues (Azure B2C)

**Provide evidence for each bottleneck using observed metrics.**

Example:
> "Database connections peaked at 85 (28% of 300 capacity) at 19:55 UTC, correlating with the learner login surge. No connection exhaustion observed."

---

### 7. Root Cause Analysis

Explain the **most likely root causes** of the observed performance limitations (or confirm no limitations found).

Clearly differentiate between:
- Application design issues
- Infrastructure limitations
- Configuration problems
- Database performance issues
- Third-party service issues (Azure B2C, SAML provider)
- Load test artifacts (issues with the test itself, not the system)

---

### 8. Key Findings

Provide a concise list of the most important conclusions.

Format:
- The system supported X concurrent users with Y% success rate.
- Database connections remained at X% of capacity.
- SSO authentication succeeded at X% rate with Y failures on [domain].
- P95 response time for [workflow] was X seconds.

---

### 9. Recommendations

Provide actionable recommendations such as:
- Architecture improvements
- Caching strategies
- Database query optimization
- Infrastructure scaling
- SSO configuration adjustments
- Monitoring improvements

---

# PHASE 2: Stakeholder Report

**Role:** You are acting as a **technical consultant preparing a performance testing report for stakeholders and engineering leadership**.

**Audience:** Clients, executives, and developers who need clear takeaways without raw metric dumps.

**Output File:** `<suite-dir>/STAKEHOLDER_REPORT.md`

**Input:** Use the TECHNICAL_ANALYSIS.md produced in Phase 1 as the source.

**Critical Requirement:** The report must remain **technically accurate**, but it should **avoid unnecessary low-level detail or raw metrics dumps**. Focus on cause and effect.

---

## Phase 2 Structure

### 1. Executive Summary

Provide a concise summary explaining:
- What testing was performed
- The overall outcome (reference TEST_PLAN.md mandates - were they met?)
- Whether infrastructure or application issues were identified
- The most important findings

Limit this section to **3-5 paragraphs** (narrative style, not bullets).

Example tone:
> Load testing of the system identified a performance limitation within the application layer rather than the infrastructure. While the underlying infrastructure remained stable under load, certain application workflows introduced significant latency due to inefficient page rendering and database query patterns.

---

### 2. Test Overview

Explain:
- Why the tests were conducted (reference TEST_PLAN.md justification)
- The type of tests performed (Protocol 1 Soak, Protocol 2 Stress, etc.)
- The tools used (Playwright for browser simulation, k6 for HTTP load)

Clarify the roles of each tool:

**Playwright**
- Simulated real user browser workflows including SSO login
- Validated UI behavior and page performance
- Ran as distributed ECS tasks for concurrency

**k6** (if applicable)
- Generated controlled backend load
- Measured request latency and throughput

---

### 3. Test Environment

Describe the architecture of the environment under test.

Include major components such as:
- Load balancer (ALB)
- Web servers (Apache)
- PHP runtime (PHP-FPM)
- Application platform (Totara LMS)
- Database (RDS PostgreSQL)
- Authentication chain (Azure B2C → ASA SAML → LMS)

Explain the general request flow without unnecessary detail.

---

### 4. Workloads Simulated

Explain the types of user activity simulated during testing.

Examples:
- Faculty login via SSO and learner access provisioning
- Learner login via SSO
- Course navigation
- Mock exam quiz workflow (start, answer questions, submit)

Clarify that these workflows represent **real user behavior in production**.

---

### 5. System Behavior Under Load

Explain how the system performed during the test.

Discuss:
- Response time behavior
- Throughput levels
- System stability
- Error rates (especially SSO failures)
- Scaling behavior

Highlight any **key thresholds where performance degraded** or confirm stability.

Example tone:
> The system remained stable through moderate load levels. However, once concurrency increased beyond the expected operational range, response times began increasing significantly for certain workflows.

OR

> The system maintained stability throughout the test period, with all metrics remaining within acceptable thresholds.

---

### 6. Key Findings

Provide a clear list of the most important findings.

Examples:
- Infrastructure remained stable during testing
- Database CPU remained within acceptable range (X% peak)
- SSO authentication achieved X% success rate
- X learners successfully completed the quiz workflow
- Y failures observed, primarily due to [cause]

Focus on **clear takeaways**.

---

### 7. Bottleneck Summary

Explain where performance limitations occurred (if any).

Clearly differentiate between:

**Application Limitations**
- Inefficient page design
- Excessive rendering of large element lists
- Inefficient database queries

**Infrastructure Limitations**
- Insufficient compute resources
- Database saturation
- Network constraints

**Third-Party Limitations**
- Azure B2C rate limiting or latency
- SAML provider issues

State clearly **which category applies** or confirm no bottlenecks identified.

---

### 8. Root Cause Explanation

Provide a simplified explanation of the root causes.

Example tone:
> The performance degradation observed during testing was primarily caused by inefficient application behavior rather than infrastructure limitations.

OR

> No significant performance degradation was observed. The system performed within expected parameters throughout the test.

Avoid raw metric dumps. Focus on **cause and effect**.

---

### 9. Recommendations

Provide actionable recommendations organized by category:

#### Immediate Actions (Before Production Event)
- [Actions needed now]

#### Application Improvements
- Paginate large lists
- Reduce DOM size
- Optimize queries

#### Infrastructure Improvements
- Horizontal scaling
- Caching improvements
- Database tuning

#### Operational Improvements
- Additional monitoring
- Workload management
- SSO configuration review

---

### 10. Verdict (Reference TEST_PLAN.md Mandates)

Provide a clear verdict against each mandate from TEST_PLAN.md:

| Mandate | Requirement | Result | Status |
|---------|-------------|--------|--------|
| Mandate 1 | [Brief requirement] | [Result] | MET/NOT MET |
| Mandate 2 | [Brief requirement] | [Result] | MET/NOT MET |

**Overall Verdict: GO / NO-GO / CONDITIONAL**

---

## Tone Requirements (Phase 2)

The report should:
- Sound professional and confident
- Avoid blame language
- Avoid overly technical jargon
- Remain technically accurate

Example tone:
> The infrastructure performed as expected under load. The primary opportunity for improvement lies within the application workflow design, where certain pages generate excessive rendering overhead.

---

## Execution Summary

When this skill runs:

1. **Parse the pasted console output** to extract suite directory path
2. **Read all relevant files** from the suite directory structure
3. **Read TEST_PLAN.md** from the project root for thresholds and mandates
4. **Generate TECHNICAL_ANALYSIS.md** (Phase 1) - engineering depth, evidence-backed
5. **Generate STAKEHOLDER_REPORT.md** (Phase 2) - client-ready, cause-and-effect focus
6. **Write both files** to the suite directory
7. **Summarize** findings to user

This produces a **two-layer reporting system**:
```
Engineering Analysis (TECHNICAL_ANALYSIS.md)
        ↓
Client Summary Report (STAKEHOLDER_REPORT.md)
```

Which is exactly how **real performance consulting reports are written**.
