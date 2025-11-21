# SAM 3 Installation Notes

This directory contains documentation of issues encountered during installation and their solutions.

## 🎉 Installation Status: **SUCCESS!**

**Date:** November 21, 2024  
**Status:** ✅ **FULLY OPERATIONAL**

SAM 3 is now successfully installed and notebooks are running at: http://localhost:8888/notebooks/sam3_image_predictor_example.ipynb

See [SUCCESS.md](./SUCCESS.md) for the full success report and [CELEBRATION.md](./CELEBRATION.md) to celebrate!

## Issues Encountered and Resolved

### Issue #001: Missing BLAS Library for NumPy Build
**Status:** RESOLVED  
**File:** [001-missing-blas-library.md](./issues/001-missing-blas-library.md)

**Problem:** NumPy 1.26.0 requires a BLAS library for compilation, but none was detected.

**Solution:** Installed `libopenblas-dev` using `sudo apt-get install -y libopenblas-dev`

---

### Issue #002: NumPy Version Conflict
**Status:** RESOLVED  
**File:** [002-numpy-version-conflict.md](./issues/002-numpy-version-conflict.md)

**Problem:** SAM 3 requires `numpy==1.26` but PyTorch 2.7.0 installs `numpy==2.3.3`.

**Solution:** The install script now handles this by using Python 3.12 when available, which allows numpy 1.26.0 to install successfully. If Python 3.12 is not available, the script relaxes the numpy constraint.

---

### Issue #003: Python Version Incompatibility
**Status:** RESOLVED  
**File:** [003-python-version-incompatibility.md](./issues/003-python-version-incompatibility.md)

**Problem:** NumPy 1.26.0 doesn't support Python 3.13+ (only supports Python 3.9-3.12).

**Solution:** The install script now automatically detects Python 3.13+ and:
1. Uses Python 3.12 if available (as recommended by README)
2. Relaxes numpy constraint if Python 3.12 is not available to allow numpy 2.3.3 from PyTorch

---

### Issue #004: Installation Successful
**Status:** COMPLETE  
**File:** [004-installation-successful.md](./issues/004-installation-successful.md)

All issues have been resolved and the installation completed successfully.

---

### Issue #005: Hugging Face Authentication
**Status:** RESOLVED  
**File:** [005-huggingface-authentication.md](./issues/005-huggingface-authentication.md)

**Problem:** SAM 3 checkpoints require Hugging Face authentication.

**Solution:** Created helper script `scripts/auth_huggingface.sh` to authenticate using `HF_TOKEN` from `.env` file.

**Usage:**
```bash
# Create .env file with your token
echo "HF_TOKEN=your_token" > .env

# Run authentication script
./scripts/auth_huggingface.sh
```

---

### Issue #006: requires-python Mismatch
**Status:** RESOLVED  
**File:** [006-requires-python-mismatch.md](./issues/006-requires-python-mismatch.md)

**Problem:** `uv run` commands fail due to `requires-python = ">=3.8"` mismatch with NumPy 1.26.0's Python requirements (`>=3.9,<3.13`).

**Solution:** Updated `pyproject.toml` to set `requires-python = ">=3.9,<3.13"` to match NumPy's requirements.

---

### Issue #007: Missing Visualization Dependencies
**Status:** RESOLVED  
**File:** [007-missing-visualization-dependencies.md](./issues/007-missing-visualization-dependencies.md)

**Problem:** `ModuleNotFoundError: No module named 'pandas'` when using `sam3.visualization_utils` in notebooks.

**Solution:** Installed missing visualization dependencies: `pandas`, `scikit-image`, `scikit-learn`. For complete notebooks support, install full notebooks dependencies: `uv pip install -e ".[notebooks]"`

## Installation Summary

✅ Installation completed successfully using Python 3.12  
✅ PyTorch 2.7.0 with CUDA 12.6 installed  
✅ SAM 3 package installed in editable mode  
✅ All dependencies resolved correctly  

## Next Steps

1. Activate the virtual environment: `source .venv/bin/activate`
2. Or use `uv run` to execute Python scripts: `uv run python <script.py>`
3. Authenticate with Hugging Face:
   - Create `.env` file with `HF_TOKEN=your_token`
   - Run: `./scripts/auth_huggingface.sh`
   - Or manually: `source .env && python -c "from huggingface_hub import login; login(token='$HF_TOKEN')"`
4. Request access to checkpoints at: https://huggingface.co/facebook/sam3 (if needed)

