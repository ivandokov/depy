#!/usr/bin/env bash
set -e

# $1 is 0 for full release and 1 for incremental

if [ $1 -eq 0 ]; then
    # Run code for full release
    echo "Full release hook"
fi

if [ $1 -eq 1 ]; then
    # Run code for incremental release
    echo "Incremental release hook"
fi