## Summary
Standard CI/CD bootstrap and repo hardening.

## Changes
- Add CI workflows (lint/test/build) where applicable
- Add repo meta files and docs

## Test Plan
- CI green on PR
- Local build runs with documented command

## Rollback
- Revert PR; no data migrations
