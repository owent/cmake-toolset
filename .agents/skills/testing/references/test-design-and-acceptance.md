# Test Design and Acceptance

Read this reference when planning, writing, or reviewing tests. Keep the work tied to cmake-toolset's current CMake/CTest
toolchain, source, CI entrypoints, and owned contracts; do not substitute generic testing theory.

## Establish evidence and risk

1. Locate the behavior source: the user requirement, public CMake function/macro, port/import contract, current consumer,
   CI failure, or reproduced defect. Inspect the exact module/port, `test/CMakeLists.txt`, fixture, and registered command.
2. State what must configure/build/run, what is most likely to fail, what has the highest impact, and which output,
   target/property, artifact, diagnostic, exit status, or runtime result proves it. Protect those risks first.
3. For every case, name the realistic production change it should catch. If it only proves a constant/source line exists,
   repeats another smoke target, or cannot fail on a real defect, remove or redesign it. If only an intentional decision
   change (a pinned version, a default option value, message wording) would fail the case, it is a change detector; test
   the configure/build behavior that depends on the decision instead.
4. If a variable, target, generator, compiler, platform, dependency, environment, or root cause is not verified, record
   the assumption/risk gap. Do not invent it or claim the test is complete across unrun configurations.

## Construct honest, minimal cases

- Start from the smallest valid fixture that exercises the owned workflow. Set only source-backed options and inputs;
  never add cache variables, feature flags, versions, paths, or environment values merely to steer the current code green.
- For an error/boundary case, change one documented precondition and assert the intended result plus material absence of
  generated/imported artifacts. Do not let an earlier missing tool, failed download, or compiler error satisfy the case.
- Use meaningful, distinguishable values and justified boundaries. Avoid copying a full consumer project or CI matrix
  into a unit-sized regression, and do not multiply equivalent port/backend cases for count.
- Derive expected values independently from the public contract or hand-checked fixture. Do not use the same CMake helper
  to create both actual and expected values, and do not test guidance/scripts by grepping their source text when they can
  be executed against controlled inputs.
- Keep decisive inputs/expectations visible. Share only stable fixture plumbing; a helper must not reproduce the module's
  decision logic. Test-only fixtures stay under `test/`, not in production modules/ports.
- A fixture project mirrors the real consumer contract completely — the declared options, languages, and dependencies the
  contract documents — not only the options the current assertion reads.

## Keep execution deterministic

- Pin source/tag/tool versions to the verified user/CI contract. Treat downloads, registries, system packages, and remote
  services as integration prerequisites; network availability is not the behavior oracle.
- Do not use wall-clock sleeps, build duration, CPU scheduling, or retry-until-pass as correctness. Use CMake/CTest
  completion, files/targets/properties, diagnostics, and process exit/output as observable synchronization/results.
- Isolate fixture build/install/output directories per case under the selected build tree. Do not depend on stale cache,
  prior test order, a developer's absolute path, or undeclared environment variables.
- Apply platform/compiler guards only when the contract is genuinely platform-specific. A skipped or build-only target
  is not executed coverage for another platform.

## Repair discipline

- When a case fails, fix the module, port, or test implementation, or redesign the case from evidence. Never weaken or
  delete an existing assertion, loosen an expected diagnostic, skip or disable a case, drop a platform guard, add a
  retry, or widen a timeout merely to reach green.
- A regression case that passes on first run proves nothing about the fix; observe the intended RED or report that it
  was not observed.
- After repeated failed fixes, stop and re-evaluate the root cause instead of stacking patches or reshaping the case to
  fit the current implementation.

## Accept with fresh evidence

- For defects and behavior changes, confirm the narrow test fails for the intended reason before the fix when practical;
  if that RED observation was not possible, report it rather than claiming test-first regression evidence.
- Inspect the resolved CTest command, run the exact case, then the affected suite/matrix in proportion to risk. Read
  configure/build/test exit codes and skipped/not-run counts.
- Mentally mutate the high-risk contract: wrong target/command, wrong branch/option propagation, missing artifact,
  unexpected success/failure, or wrong generated-tool path. A focused assertion should catch each claimed risk.
- Reject or redesign a case when: setup and assertion share the same helper logic; it fails only via environment or
  download errors and never on a contract violation; it fails on intentional refactors but not on realistic defects; it
  greps source text instead of executing the configure/build; or it exists only for a count.
- Report source-derived conclusions, configured/built targets, executed tests, smoke-only evidence, skips, and unverified
  generators/platforms separately.
