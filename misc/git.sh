#!/bin/bash
set -e
echo "{\"organization\":\"$(/usr/bin/git remote get-url origin | sed 's/.*github.com.\(.*\)\/.*/\1/')\"}"
