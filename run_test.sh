#!/usr/bin/env bash

usage () { echo "bash run_test.h -t <test_ids>"; }

while getopts ":t:h" opt; do
    case $opt in
        t) test_args+=("$OPTARG");;
        h) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $((OPTIND -1))


#command for running 
cmd="NXF_VER=20.11.0-edge nextflow run"

#databases
bowtie="--bowtie2_index hg19_1kgmaj --bowtie_index_name hg19_1kgmaj"
kraken="--kraken_db k2_pluspf_16gb"

for id in "${test_args[@]}"; do
    script="test_scripts/mainscripts/${id}_main.nf"
    input_dir="data/$id"
    output_dir="${id}_out"
    $cmd $script --input_dir $input_dir --output_dir output $bowtie $kraken
    echo $cmd
done