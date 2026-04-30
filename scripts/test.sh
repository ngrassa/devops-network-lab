#!/bin/bash
echo "Testing connectivity..."
docker exec pc1 ping -c 2 pc3
