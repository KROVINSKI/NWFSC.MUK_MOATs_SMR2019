#!/bin/sh

# Rename all files from .lvm to .txt
for f in *.lvm; do
    mv -- "$f" "${f%.lvm}.txt"
done
