#!/bin/bash

fish
bash
sh
busybox sh
ls
while true; do
    read -p ": " cmd
    eval $cmd
done
echo test
sleep 1d 