#!/bin/bash

sudo ip addr add 192.168.1.65/27 dev enp3s0
sudo ip r add 192.168.1.94 dev enp3s0
sudo ip route add 192.168.0.0/16 via 192.168.1.94 dev enp3s0
