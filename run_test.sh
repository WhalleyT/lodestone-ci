#!/usr/bin/env bash

usage () { 
    echo ""
    echo "bash run_test.h -t <test_ids> -k <kraken_db> -b <bowtie_db> -i <bowtie_index>"; 
    echo -e "\t-t <test_ids>: string of of test IDs. These can be TM[01-10]. \
    \n\t\tMultiple arguments can be supplied but they must each have the -t flag before \
    \n\t\tthem e.g. -t TM01 -t TM02"
    echo -e "\t-k <kraken_db>: Kraken2 database directory. Default = pluspf_16gb"
    echo -e "\t-b <bowtie_db>: Bowtie database directory. Default = hg19_1kgmaj"
    echo -e "\t-i <index>: Bowtie index prefix. Default = hg19_1kgmaj"
    echo ""
    }

profile=""
index="hg19_1kgmaj"
bowtie_db="hg19_1kgmaj"
kraken_db="pluspf_16gb"


while getopts ":t:k:b:i:ph" opt; do
    case $opt in
        t) test_args+=("$OPTARG");;
        k) kraken_db=$OPTARG;;
        b) bowtie_db=$OPTARG;;
        i) index=$OPTARG;;
        p) profile="-profile singularity";;
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
bowtie="--bowtie2_index $bowtie_db --bowtie_index_name $index"
kraken="--kraken_db $kraken_db"


for id in "${test_args[@]}"; do
    script="test_scripts/mainscripts/${id}_main.nf"
    input_dir="data/$id"
    output_dir="${id}_out"
    nextflow run $script --input_dir $input_dir --output_dir output $bowtie $kraken $pattern $profile --pattern '*_{1,2}.fq.gz' -with-report
    #mv report.html ${id}_report.html
    #rm -r work/
done

