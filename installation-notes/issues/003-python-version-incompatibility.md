# Issue #003: Python Version Incompatibility with NumPy 1.26.0

## Problem
The installation fails with error:
```
meson-python: error: Unsupported Python version 3.13.5, expected <3.13,>=3.9
```

## Root Cause
- The system has Python 3.13.5 installed
- NumPy 1.26.0 only supports Python versions 3.9 through 3.12 (not 3.13)
- PyTorch 2.7.0 installs numpy 2.3.3 which does support Python 3.13
- SAM 3's pyproject.toml specifies `numpy==1.26` which forces building numpy 1.26.0 from source, which fails on Python 3.13

## Solution
Since PyTorch 2.7.0 already provides numpy 2.3.3 which is compatible with Python 3.13, we should relax the numpy version constraint to allow using the numpy version provided by PyTorch.

Options:
1. **Relax numpy constraint** (recommended): Change `numpy==1.26` to `numpy>=1.26` to allow numpy 2.3.3 from PyTorch
2. **Use Python 3.12**: Create the venv with Python 3.12 instead of 3.13
3. **Check compatibility**: Test if numpy 2.3.3 is compatible with SAM 3

## Resolution
Since PyTorch 2.7.0 already provides numpy 2.3.3 which is compatible with Python 3.13, we should relax the numpy version constraint to allow using the numpy version provided by PyTorch.

The install script now:
1. Checks if Python 3.12 is available and uses it (as recommended by README)
2. If Python 3.13 is being used, temporarily relax numpy constraint to `numpy>=1.26` to allow numpy 2.3.3 from PyTorch
3. Installs package with appropriate constraints

**Status: RESOLVED**
- The script now detects Python 3.13+ and automatically uses Python 3.12 if available
- In this case, Python 3.12 was found and used, allowing numpy 1.26.0 to install successfully
- If Python 3.12 is not available, the script will relax the numpy constraint to allow numpy 2.3.3 from PyTorch

