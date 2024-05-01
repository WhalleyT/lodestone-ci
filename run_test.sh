#!/usr/bin/env bash

set -a


usage () { 
    echo ""
    echo "bash run_test.h -t <test_ids> -k <kraken_db> -b <bowtie_db> -i <bowtie_index> -a <afanc_db> -r <resource_db>"; 
    
    echo -e "\t-t <test_ids>: string of of test IDs. These can be TM[01-10]. \
    \n\t\tMultiple arguments can be supplied but they must each have the -t flag before \
    \n\t\tthem e.g. -t TM01 -t TM02"
    
    echo -e "\t-d <data>: Directory containing test data. Default = s3://microbial-bioin-sp3/Lodestone_Testing_1.0/"
    echo -e "\t-k <kraken_db>: Kraken2 database directory. Default = <empty>"
    echo -e "\t-b <bowtie_db>: Bowtie database directory. Default = <empty>"
    echo -e "\t-i <bowtie_index>: Bowtie index prefix. Default = <empty>"
    echo -e "\t-a <afanc_db>: Afanc database directory. Default = <empty>"
    echo -e "\t-r <resource_db>: Resource directory. Default = <empty>"
    echo -e "\t-p <profile>: Nextflow profile. Default = climb"
    echo ""
    }

profile=""
bowtie_index=""
bowtie_db=""
kraken_db=""
afanc_db=""
resource_db=""


while getopts ":t:k:b:i:a:r:ph" opt; do
    case $opt in
        t) test_args+=("$OPTARG");;
        k) kraken_db=$OPTARG;;
        b) bowtie_db=$OPTARG;;
        i) index=$OPTARG;;
        a) afanc_db=$OPTARG;;
        r) resource_db=$OPTARG;;
        p) profile="$OPTARG";;
        h) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $((OPTIND -1))

#recursively copy and update any scripts into new location so we don't have to override basedir in NF
cp -R -u -p lodestone/nextflow.config test_scripts/mainscripts
cp -R -u -p lodestone/config test_scripts/mainscripts
cp -R -u -p lodestone/singularity test_scripts/mainscripts
cp -R -u -p lodestone/docker test_scripts/mainscripts
cp -R -u -p lodestone/bin test_scripts/mainscripts

######
# If an arg is not empty, then we can add the flag to it to pass it into nextflow
######

echo $profile

if [[ $bowtie_db != "" ]]; then
    bowtie_db="--bowtie_index $bowtie_db"
fi

if [[ $bowtie_index != "" ]]; then
    bowtie_index_name="--bowtie_index $bowtie_index"
fi


if [[ $kraken_db != "" ]]; then
    kraken_db="--kraken_db $kraken_db"
fi


if [[ $afanc_db != "" ]]; then
    afanc_db="--afanc_myco_db $afanc_db"
fi

if [[ $resource_db != "" ]]; then
    resource_db="--resource_dir $resource_db"
fi

if [[ $profile == "" ]]; then
    #go to our default
    profile="-profile climb"
else
    profile="-profile $profile"
fi

if [[ $data == "" ]]; then
    #go to our default
    data="s3://microbial-bioin-sp3/Lodestone_Testing_1.0/"
fi

if [[ $test_args == "" ]]; then
    echo "--test_args/-t must not be empty"
    exit 1
fi

#add trailing slash if needed
data="${data%/}/"


echo "Nextflow will run with the following invocation:"
echo -e "\tnextflow run <test_module>.nf --input_dir ${data}<test_module> --output_dir output/<test_module> \
$bowtie_db $bowtie_index $kraken_db $profile --pattern '*_{1,2}.fq.gz' -with-report"

for id in "${test_args[@]}"; do
    #set input and output and find test script
    script="test_scripts/mainscripts/${id}_main.nf"
    input_dir="${data}${id}"
    output_dir="${id}_out"
    
    #run it
    nextflow run $script --input_dir $input_dir --output_dir output \
    $bowtie_db $bowtie_index $kraken_db $profile \
    --pattern '*_{1,2}.fq.gz' -with-report report.html
    
    if [ -f report.html ]; then
        mv report.html ${id}_report.html
    fi
    
    rm -rf work/
done
