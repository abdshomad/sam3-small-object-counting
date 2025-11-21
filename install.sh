#!/bin/bash
# SAM 3 Installation Script
# This script installs SAM 3 using uv venv as per cursor rules

set -e  # Exit on any error

echo "========================================="
echo "SAM 3 Installation Script"
echo "========================================="
echo ""

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "ERROR: uv is not installed."
    echo "Please install uv first:"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "  or visit: https://github.com/astral-sh/uv"
    exit 1
fi

echo "✓ uv is installed"
echo ""

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
REQUIRED_VERSION="3.12"
if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "WARNING: Python 3.12 or higher is recommended."
    echo "  Current version: $(python3 --version)"
    echo "  Continuing anyway..."
fi

# Check for BLAS libraries (required for numpy build)
echo "Checking for BLAS libraries..."
if ! (pkg-config --exists openblas 2>/dev/null || pkg-config --exists blas 2>/dev/null || ldconfig -p | grep -q libopenblas 2>/dev/null); then
    echo "⚠ BLAS library not detected. Attempting to install..."
    if command -v apt-get &> /dev/null; then
        echo "  Installing libopenblas-dev (requires sudo)..."
        sudo apt-get update && sudo apt-get install -y libopenblas-dev
        echo "✓ BLAS library installed"
    elif command -v yum &> /dev/null; then
        echo "  Installing openblas-devel (requires sudo)..."
        sudo yum install -y openblas-devel
        echo "✓ BLAS library installed"
    else
        echo "  WARNING: Could not automatically install BLAS library."
        echo "  Please install OpenBLAS manually:"
        echo "    Ubuntu/Debian: sudo apt-get install libopenblas-dev"
        echo "    CentOS/RHEL: sudo yum install openblas-devel"
        echo "  Continuing anyway, numpy build may fail..."
    fi
else
    echo "✓ BLAS library detected"
fi
echo ""

# Check if CUDA is available (optional check)
if command -v nvidia-smi &> /dev/null; then
    echo "✓ NVIDIA GPU detected"
    CUDA_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -n1)
    echo "  Driver version: $CUDA_VERSION"
else
    echo "⚠ NVIDIA GPU not detected. SAM 3 requires CUDA for optimal performance."
fi
echo ""

# Check Python version and handle numpy 1.26.0 incompatibility with Python 3.13+
PYTHON_VERSION_FULL=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PYTHON_VERSION_MINOR=$(python3 -c "import sys; print(sys.version_info.minor)")

echo "Detected Python version: $PYTHON_VERSION_FULL"
RELAX_NUMPY=""
PYTHON_CMD="python3"

if [ "$PYTHON_VERSION_MINOR" -ge 13 ]; then
    echo "⚠ Warning: Python 3.13+ detected. NumPy 1.26.0 doesn't support Python 3.13+"
    echo "  Checking for Python 3.12..."
    
    # Try to find Python 3.12
    if command -v python3.12 &> /dev/null; then
        echo "  Found Python 3.12, will use it for the virtual environment"
        PYTHON_CMD="python3.12"
    else
        echo "  Python 3.12 not found. Will use Python 3.13 and relax numpy constraint."
        echo "  (NumPy will use version 2.3.3 from PyTorch instead of 1.26.0)"
        RELAX_NUMPY=1
    fi
fi
echo ""

# Create uv virtual environment
echo "Step 1: Setting up uv virtual environment..."
if [ -d ".venv" ]; then
    echo "  .venv already exists. Using existing environment..."
else
    echo "  Creating new virtual environment with $PYTHON_CMD..."
    if [ -n "$PYTHON_CMD" ] && [ "$PYTHON_CMD" != "python3" ]; then
        uv venv --python "$PYTHON_CMD"
    else
        uv venv
    fi
    echo "✓ Virtual environment created"
fi
echo ""

# Activate the virtual environment
echo "Step 2: Activating virtual environment..."
source .venv/bin/activate
echo "✓ Virtual environment activated"
echo ""

# Install PyTorch with CUDA support
echo "Step 3: Installing PyTorch 2.7.0 with CUDA 12.6 support..."
uv pip install torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
echo "✓ PyTorch installed"
echo ""

# Install the package in editable mode
echo "Step 4: Installing SAM 3 package..."
echo ""

# Check if we need to relax numpy constraint for Python 3.13+
if [ -n "$RELAX_NUMPY" ]; then
    echo "Python 3.13+ detected. Temporarily relaxing numpy constraint..."
    echo "  Original: numpy==1.26"
    echo "  Using: numpy>=1.26 (will use numpy 2.3.3 from PyTorch)"
    echo ""
    
    # Backup pyproject.toml
    if [ -f "pyproject.toml" ]; then
        cp pyproject.toml pyproject.toml.backup
        # Relax numpy constraint
        sed -i 's/numpy==1.26/numpy>=1.26/' pyproject.toml
        echo "✓ Temporarily modified pyproject.toml to relax numpy constraint"
        echo ""
    fi
fi

# Try installing SAM 3 package
# Capture output to check for errors
INSTALL_OUTPUT=$(uv pip install -e . 2>&1) || INSTALL_FAILED=1

if [ -n "$INSTALL_FAILED" ]; then
    echo "$INSTALL_OUTPUT"
    echo ""
    
    # Check if error is related to Python version incompatibility
    if echo "$INSTALL_OUTPUT" | grep -q "Unsupported Python version\|expected <3.13"; then
        echo "Detected Python version incompatibility with numpy 1.26.0"
        echo "Attempting to install with relaxed numpy constraint..."
        echo ""
        
        # Relax numpy constraint if not already done
        if [ -z "$RELAX_NUMPY" ] && [ -f "pyproject.toml" ]; then
            cp pyproject.toml pyproject.toml.backup
            sed -i 's/numpy==1.26/numpy>=1.26/' pyproject.toml
            echo "✓ Temporarily modified pyproject.toml to relax numpy constraint"
            echo ""
        fi
        
        # Try installing again with relaxed constraint
        if uv pip install -e .; then
            echo "✓ SAM 3 package installed (with relaxed numpy constraint)"
        else
            echo ""
            echo "Installation still failing. Please check errors above."
            # Restore pyproject.toml
            if [ -f "pyproject.toml.backup" ]; then
                mv pyproject.toml.backup pyproject.toml
            fi
            exit 1
        fi
    # Check if error is related to BLAS/numpy build
    elif echo "$INSTALL_OUTPUT" | grep -q "BLAS\|No BLAS\|allow-noblas"; then
        echo "Detected BLAS-related error during numpy build."
        echo "Note: BLAS libraries should be installed (libopenblas-dev)"
        echo ""
        echo "If this error persists, please ensure BLAS is properly installed:"
        echo "  sudo apt-get install libopenblas-dev"
        echo ""
        exit 1
    else
        echo ""
        echo "Installation failed for other reasons. Please check the error above."
        exit 1
    fi
else
    echo "$INSTALL_OUTPUT"
    echo "✓ SAM 3 package installed"
fi

# Restore pyproject.toml if it was modified
if [ -f "pyproject.toml.backup" ]; then
    mv pyproject.toml.backup pyproject.toml
    echo "✓ Restored original pyproject.toml"
fi

echo ""

# Ask user if they want to install additional dependencies
echo "Step 5: Additional dependencies"
echo ""
echo "Would you like to install additional dependencies?"
echo "  [1] Notebooks only (for running example notebooks)"
echo "  [2] Development and training (for development work)"
echo "  [3] Both (notebooks + dev + train)"
echo "  [4] Skip (basic installation only)"
echo ""
read -p "Enter your choice [1-4] (default: 4): " choice
choice=${choice:-4}

case $choice in
    1)
        echo "Installing notebooks dependencies..."
        uv pip install -e ".[notebooks]"
        echo "✓ Notebooks dependencies installed"
        ;;
    2)
        echo "Installing development and training dependencies..."
        uv pip install -e ".[dev,train]"
        echo "✓ Development and training dependencies installed"
        ;;
    3)
        echo "Installing all additional dependencies..."
        uv pip install -e ".[notebooks,dev,train]"
        echo "✓ All additional dependencies installed"
        ;;
    4)
        echo "Skipping additional dependencies"
        ;;
    *)
        echo "Invalid choice. Skipping additional dependencies."
        ;;
esac
echo ""

echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""
echo "To use SAM 3, activate the virtual environment:"
echo "  source .venv/bin/activate"
echo ""
echo "Or use uv run to execute Python scripts:"
echo "  uv run python <script.py>"
echo ""
echo "Important: Before using SAM 3, you need to:"
echo "  1. Request access to checkpoints at: https://huggingface.co/facebook/sam3"
echo "  2. Authenticate with Hugging Face: hf auth login"
echo ""
echo "For running Jupyter notebooks:"
echo "  uv run jupyter notebook examples/sam3_image_predictor_example.ipynb"
echo ""

