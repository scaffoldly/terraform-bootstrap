#!/bin/bash
set -e
echo "{\"repo\":\"$(git remote get-url origin)\"}"
