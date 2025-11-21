# Issue #001: Missing BLAS Library for NumPy Build

## Problem
When installing SAM 3 package, the installation fails with an error during numpy 1.26.0 build:

```
ERROR: Problem encountered: No BLAS library detected! Install one, or use the `allow-noblas` build option
```

## Root Cause
NumPy 1.26.0 requires a BLAS (Basic Linear Algebra Subprograms) library for compilation. The system doesn't have OpenBLAS or another BLAS library installed, causing the build to fail.

## Solution
We have two options:

1. **Install system BLAS library** (recommended for performance):
   - Install OpenBLAS: `sudo apt-get install libopenblas-dev` or similar
   
2. **Use allow-noblas build option** (simpler but slower):
   - Use numpy's `allow-noblas` build option, though this may be up to 100x slower for some linear algebra operations

Since the requirements specify numpy==1.26.0 in pyproject.toml but PyTorch 2.7.0 installs numpy 2.3.3, there's also a version conflict. The best approach is to install system BLAS libraries and allow numpy to be resolved from the dependency tree.

## Resolution
Install system BLAS libraries (libopenblas-dev) before running the installation script.

**Status: RESOLVED**
- Installed libopenblas-dev using: `sudo apt-get install -y libopenblas-dev`
- BLAS library is now available for numpy builds
- The script now detects BLAS libraries correctly

