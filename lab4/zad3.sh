#!/bin/bash

echo "VOLUME NAME   SIZE    USAGE"
echo "-------------------------------"

volumes=$(docker volume ls -q)

if [ -z "$volumes" ]; then
    echo "Nie znaleziono żadnych wolumenów"
    exit 0
fi

total_size=0
for volume in $volumes; do
    size_bytes=$(docker run --rm -v $volume:/volume alpine:latest sh -c "find /volume -type f -exec ls -l {} \; | awk '{sum+=\$5} END {print sum}'")

    total_size=$((total_size + size_bytes))
done

if [ "$total_size" -eq 0 ]; then
    total_size=1
fi


for volume in $volumes; do
    size_bytes=$(docker run --rm -v $volume:/volume alpine:latest sh -c "find /volume -type f -exec ls -l {} \; | awk '{sum+=\$5} END {print sum}'")
    
    if [ "$size_bytes" -eq 0 ]; then
        size="0B"
    elif [ "$size_bytes" -lt 1024 ]; then
        size="${size_bytes}B"
    elif [ "$size_bytes" -lt 1048576 ]; then
        size="$(echo "scale=1; $size_bytes/1024" | bc)K"
    else
        size="$(echo "scale=1; $size_bytes/1048576" | bc)M"
    fi
    
    usage=$(echo "scale=1; $size_bytes*100/$total_size" | bc)

    printf "%-12s %-8s %s%%\n" "$volume" "$size" "$usage"
done