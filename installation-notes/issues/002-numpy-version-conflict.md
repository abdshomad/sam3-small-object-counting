# Issue #002: NumPy Version Conflict

## Problem
The pyproject.toml specifies `numpy==1.26` as a dependency, but PyTorch 2.7.0 installs `numpy==2.3.3`. This creates a version conflict during package installation.

## Root Cause
- SAM 3 requires: `numpy==1.26`
- PyTorch 2.7.0 provides: `numpy==2.3.3`
- When trying to install SAM 3, it attempts to build numpy 1.26.0 from source, which requires BLAS libraries

## Solution Options

1. **Allow numpy to be resolved from dependency tree** (recommended):
   - Remove strict pinning of numpy==1.26
   - Use numpy>=1.26 to allow dependency resolver to find compatible version
   - PyTorch's numpy version might be compatible

2. **Downgrade numpy after PyTorch installation**:
   - Install PyTorch first (gets numpy 2.3.3)
   - Then downgrade to numpy 1.26 if needed

3. **Check compatibility**:
   - Test if numpy 2.3.3 works with SAM 3
   - If yes, update pyproject.toml to allow newer numpy

## Resolution
Install BLAS libraries first to allow building numpy from source if needed, then let the dependency resolver handle the version conflict. If conflicts persist, we may need to relax the numpy version constraint.

