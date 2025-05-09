# Changelog

## [1.0.0] - 2025-05-09

### Added
- Athena Named Queries for EBS cost and usage analysis (requires CUR + Glue + Athena setup).
- Cost Category creation in AWS Cost Explorer to group and track EBS costs.
- CloudWatch Composite Alarms combining ReadOps, WriteOps, and BurstBalance per volume.
- Optional CloudWatch Dashboard with dynamic widgets.
- Auto-tagging (`Environment`, `CostCenter`, `ManagedBy`) for all created resources.
- Example project for real and fake mode.
- Minimal IAM policy example (`iam-policy-minimal.json`) for least privilege deployments.

### Improved
- Refactored module structure to separate alarms, SNS, and dashboard resources.
- Updated documentation with clearer usage examples.
- Added fake mode (`use_fake_data = true`) for local testing and CI/CD.

### Fixed
- Corrected conditional logic for real vs. fake data modes.
- Fixed tag propagation across all resources.

### Breaking Changes
- The `cost_center` variable is now required if you want to set the `CostCenter` tag.
- Fake mode must be explicitly enabled in example configurations (`use_fake_data = true`).
