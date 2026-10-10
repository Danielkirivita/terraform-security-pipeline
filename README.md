# Terraform Security Pipeline

[![Terraform Security Gate](https://github.com/Danielkirivita/terraform-security-pipeline/actions/workflows/security.yml/badge.svg)](https://github.com/Danielkirivita/terraform-security-pipeline/actions/workflows/security.yml)

An automated AWS infrastructure-as-code (IaC) security pipeline using Terraform, Trivy, and GitHub Actions.

## Project Objectives

- Detect cloud misconfigurations before deployment.
- Reject HIGH and CRITICAL security findings.
- Validate secure Terraform remediation.
- Test CI/CD enforcement with intentionally insecure pull requests.

## Technology Stack

- Terraform (AWS infrastructure definitions)
- Trivy v0.75.0 (static security scanning)
- GitHub Actions (CI/CD)
- GitHub branch protection (required status checks)
- Git (version control)

## Architecture

Terraform source
    |
    v
GitHub Pull Request
    |
    v
GitHub Actions
    |
    v
Trivy Configuration Scan
    |
    +-- HIGH / CRITICAL findings -> FAIL
    |
    +-- No HIGH / CRITICAL findings -> PASS

A separate regression fixture verifies that known insecure
configurations produce a failing scan.

## Security Checks

| Area | Security Check |
| --- | --- |
| Network security | Detect unrestricted SSH ingress |
| S3 access control | Detect disabled public-access safeguards |
| S3 encryption | Detect missing customer-managed KMS encryption |
| CI/CD | Fail on HIGH or CRITICAL findings |
| Regression testing | Reject intentionally vulnerable Terraform |
| Branch governance | Require the IaC Security Scan check |

## Measured Outcomes

| Test | Result |
| --- | --- |
| Initial vulnerable configuration | 6 HIGH findings |
| Remediated configuration | 0 HIGH/CRITICAL findings |
| Local regression checks | Passed |
| Baseline GitHub Actions workflow | Passed |
| Public SSH pull-request test | Failed as expected |
| Required PR security check | Blocked normal merge |

### Verified CI/CD Evidence

- [Successful baseline workflow](https://github.com/Danielkirivita/terraform-security-pipeline/actions/runs/38011597531)
- [Failed public SSH security test](https://github.com/Danielkirivita/terraform-security-pipeline/actions/runs/38012734569)
- [Blocked pull request #1](https://github.com/Danielkirivita/terraform-security-pipeline/pull/1)

The pull-request test introduced 0.0.0.0/0 on TCP port 22.
Trivy reported AWS-0107 (HIGH), exited with code 1,
and failed the required GitHub Actions check.

The pull request was closed without merging.

## Repository Structure

infra/main.tf
    Remediated Terraform configuration.

fixtures/vulnerable/main.tf
    Deliberately vulnerable training configuration.

.github/workflows/security.yml
    Automated CI/CD security gate.

## Local Reproduction

Install Trivy v0.75.0, then run:

```bash
trivy config --severity HIGH,CRITICAL --exit-code 1 infra
trivy config --severity HIGH,CRITICAL --exit-code 1 fixtures/vulnerable
```

Expected exit codes:
- Secure configuration: 0
- Vulnerable fixture: 1

## Scope and Limitations

- Static analysis only; no infrastructure was deployed.
- No real AWS credentials or resources are required.
- Passing selected checks does not establish full security.
- Trivy did not identify the wildcard IAM policy in the
  initial example; additional IAM-specific validation
  would improve coverage.
- Repository administrators may have bypass privileges
  depending on branch protection configuration.

## Future Improvements

- Add IAM least-privilege policy checks.
- Export SARIF security results.
- Improve regression tests to verify specific finding IDs.
- Add Terraform formatting and validation checks.
- Pin CI dependencies to immutable commit SHAs.