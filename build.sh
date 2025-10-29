#!/usr/bin/env bash
# Build script for Render deployment

set -e  # Exit on error

echo "========================================="
echo "  Building agendaRenta4 for Render"
echo "========================================="
echo

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt
echo "✓ Dependencies installed"
echo

echo "========================================="
echo "  Build completed successfully"
echo "========================================="
