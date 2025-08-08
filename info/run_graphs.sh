#!/bin/bash

set -e  # Exit if any command fails

echo "Running unpack_sequence..."
python graphs.py unpack_sequence

echo "Running json_dumps..."
python graphs.py json_dumps

echo "Running pickle..."
python graphs.py pickle

echo "All done!"
