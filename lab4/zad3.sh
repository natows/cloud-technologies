#!/bin/bash

echo "VOLUME NAME   SIZE"
echo "----------------------"

volumes=$(docker volume ls -q)


if [ -z "$volumes" ]; then
    echo "Nie znaleziono żadnych wolumenów"
    exit 0
fi

for volume in $volumes; do
    size=$(docker run --rm -v $volume:/volume alpine:latest sh -c "find /volume -type f -exec ls -l {} \; | awk '{sum+=\$5} END {if(sum==0) print \"0B\"; else if(sum<1024) print sum\"B\"; else if(sum<1048576) print sum/1024\"K\"; else print sum/1048576\"M\"}'")
    
    links=$(docker inspect $volume | grep -c "\"Name\": \"$volume\"")
    
    printf "%-12s %-8d %s\n" "$volume" "$links" "$size"
done