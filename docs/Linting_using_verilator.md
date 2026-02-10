# RTL Linting Guide (Verilator)

## Purpose

All RTL must pass Verilator lint checks before being submitted in a pull request.

Linting detects issues that may not appear in simulation but can cause synthesis, timing, or integration failures.

Examples include:

* latch inference
* width mismatches
* combinational loops
* unused or undriven signals
* missing connections

A pull request must not introduce new lint warnings or errors.

---

## Installation

Designers must install Verilator locally.

### Ubuntu / Debian

```bash
sudo apt-get update
sudo apt-get install verilator
```

### Fedora

```bash
sudo dnf install verilator
```

### macOS (Homebrew)

```bash
brew install verilator
```



## Verify Installation

```bash
verilator --version
```

Expected output:

```
Verilator 5.x
```

---

## Lint Command

Run lint before committing or opening a PR.

```bash
verilator --lint-only -Wall <rtl_files>
```

Example with include paths:

```bash
verilator --lint-only -Wall \
-Isrc/rtl \
-Isrc/common \
<rtl_files>
```
## What Must Be Linted

Designers must lint:

- All newly added RTL files
- All modified RTL files
- Any module affected by interface changes
- Top-level integration files when wiring changes are made

---

## Verilator Message Types

Verilator reports three types of messages:

* **Error** — prevents compilation
* **Warning** — indicates potential RTL bugs
* **Info** — informational messages

Team policy requires **zero warnings and zero errors**.

Warnings may be promoted to errors in CI:

```bash
verilator --lint-only -Wall -Werror
```

---

## Common Lint Warning Categories

Designers should recognize these common warnings:

* **LATCH** — inferred latch due to incomplete combinational logic
* **WIDTH** — truncation or width mismatch
* **UNUSED** — unused signal or register
* **UNDRIVEN** — signal declared but never assigned
* **UNOPTFLAT** — combinational loop or circular dependency
* **CASEINCOMPLETE** — incomplete case statement
* **PINMISSING** — missing module port connection

These warnings typically indicate real RTL issues and must be fixed.

---

## Lint Suppression Policy

Warnings must not be suppressed unless intentional and documented.

Example:

```verilog
/* verilator lint_off UNUSED */
wire unused_debug_signal;
/* verilator lint_on UNUSED */
```

All lint suppression must be justified in code review.

---

## Recommended Lint Workflow

1. Run lint locally before committing.
2. Fix warnings in priority order:

   * LATCH
   * UNOPTFLAT
   * WIDTH
   * UNDRIVEN
   * UNUSED
3. Re-run lint until clean.
4. Maintain a zero-warning baseline.

---

## Designer Checklist

Before opening a PR:

* Verilator lint runs successfully
* No warnings or errors remain
* All modified RTL files are linted

## Reference

For additional background on RTL linting and common Verilator warnings:

- [Linting Your Design (ChipVerify)](https://www.chipverify.com/rtl-to-synthesis/linting-your-design)
