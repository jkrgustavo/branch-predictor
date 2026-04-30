#!/bin/bash

set -e

BENCH_DIR="benchmarks"
OUTPUT_DIR="traces"
BUILD_DIR="build"

mkdir -p "$OUTPUT_DIR" "$BUILD_DIR"

EXCLUDE=(
    "kinda-random.s"
    "print-trace.s"
)

for file in "$BENCH_DIR"/*.s; do
    base=$(basename "$file")

    skip=false
    for excluded in "${EXCLUDE[@]}"; do
        if [[ "$base" == "$excluded" ]]; then
            skip=true
            break
        fi
    done

    if [[ "$skip" == true ]]; then
        continue
    fi

    name=$(basename "$file" .s)

    echo "building $name..."
    clang "$file" "$BENCH_DIR/print-trace.s" "$BENCH_DIR/kinda-random.s" -o "$BUILD_DIR/$name"

    echo "running $name..."
    "$BUILD_DIR/$name" > "$OUTPUT_DIR/$name"

    echo "Wrote $OUTPUT_DIR/$name"
done
