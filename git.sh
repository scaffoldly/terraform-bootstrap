#!/bin/bash
set -e
echo "{\"repo\":\"$(/usr/bin/git remote get-url origin)\"}"
