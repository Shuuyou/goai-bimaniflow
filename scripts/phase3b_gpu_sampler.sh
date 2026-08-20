#!/usr/bin/env bash
# Phase 3B GPU sampler: log nvidia-smi every 5s to the given file. Usage: gpu_sampler.sh <out> [seconds]
out="$1"; dur="${2:-3600}"
end=$((SECONDS + dur))
while [ $SECONDS -lt $end ]; do
  echo "$(date +%H:%M:%S) $(nvidia-smi --query-gpu=memory.used,utilization.gpu,temperature.gpu --format=csv,noheader,nounits)" >> "$out"
  sleep 5
done
