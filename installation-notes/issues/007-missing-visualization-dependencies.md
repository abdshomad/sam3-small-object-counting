# Issue #007: Missing Visualization Dependencies

## Problem
When trying to use `sam3.visualization_utils` in a notebook, the following error occurs:

```
ModuleNotFoundError: No module named 'pandas'
```

## Root Cause
The `sam3/visualization_utils.py` module imports several dependencies that are listed in optional dependency groups (`dev` and `notebooks`):

- `pandas` - in `dev` optional dependencies
- `opencv-python` (cv2) - in both `dev` and `notebooks` optional dependencies  
- `matplotlib` - in `notebooks` optional dependencies
- `scikit-image` (skimage) - in `notebooks` optional dependencies
- `scikit-learn` (sklearn) - in `notebooks` optional dependencies
- `pycocotools` - in both `dev` and `notebooks` optional dependencies

However, when installing SAM 3 with only the base dependencies (without optional dependencies), these packages are not installed.

## Solution
Install the notebooks optional dependencies which include most visualization dependencies:

```bash
uv pip install -e ".[notebooks]"
```

Or install specific missing packages:

```bash
uv pip install pandas scikit-image scikit-learn
```

**Note:** Since `visualization_utils` is part of the core `sam3` package and is used in example notebooks, these dependencies should ideally be available when running notebooks.

## Resolution
**Status:** RESOLVED

- Installed missing visualization dependencies: `pandas`, `scikit-image`, `scikit-learn`
- For complete notebooks support, install full notebooks dependencies: `uv pip install -e ".[notebooks]"`

## Recommendations
For users planning to use SAM 3 with notebooks:

1. **Install notebooks dependencies during installation:**
   ```bash
   ./install.sh
   # Choose option 1 or 3 to install notebooks dependencies
   ```

2. **Or install after installation:**
   ```bash
   source .venv/bin/activate
   uv pip install -e ".[notebooks]"
   ```

This ensures all visualization and notebook dependencies are available.

