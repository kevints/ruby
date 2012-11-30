#!/bin/bash

make clean
make miniruby
RESULTS_DIR=./bench_results
GOOD_BENCH=./miniruby_bench
mkdir -p $RESULTS_DIR
mkdir -p 
for script in `ls ./benchmark`;
do
    bench_out=$RESULTS_DIR/$script"_out"
    echo Benching $script
    ./miniruby ./benchmark/$script > $bench_out

    RETVAL=$?
    if [ $RETVAL -eq 0 ] 
        then
        cp ./benchmark/$script $GOOD_BENCH
        
    else
        echo $script failed
        rm $bench_out
    fi
done


