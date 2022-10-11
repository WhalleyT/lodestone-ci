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

#recursively copy and update any scripts into new location so we don't have to override basedir in NF
cp -R -u -p tb-pipeline/bin test_scripts/mainscripts

#databases
bowtie="--bowtie2_index hg19_1kgmaj --bowtie_index_name hg19_1kgmaj"
kraken="--kraken_db k2_pluspf_16gb"
profile="-profile singularity"


NXF_SINGULARITY_CACHEDIR="singularity"
for id in "${test_args[@]}"; do
    script="test_scripts/mainscripts/${id}_main.nf"
    input_dir="data/$id"
    output_dir="${id}_out"
    nextflow run $script --input_dir $input_dir --output_dir output $bowtie $kraken $pattern $profile --pattern '*_{1,2}.fq.gz' -with-report
    mv report.html ${id}_report.html
done

