# Lodestone Testing

## Aims
This repositry is designed to perform automated testing of [Lodestone](https://github.com/Pathogen-Genomics-Cymru/lodestone) pipeline. It takes test datasets help in an [S3 bucket](https://microbial-bioin-sp3.s3.climb.ac.uk/Lodestone_Testing_1.0/), downloads them along with the requisite Kraken2 and Bowtie databases and runs the nextflow pipeline against them based on changes to the module module files.

## Usage
This repo is primarily intended to be automated. However, the test scripts can still be ran as follows:

```"bash run_test.sh -t <test_ids>```

Where ```_test_ids``` refers to the test ID, ranging from TM01 to TM10. Multiple arguments can be supplied. Additional arguments can be supplied to point to the correct Kraken2 and Bowtie databases, as well to run the script with or without singularity. See ```bash run_test.sh -h``` for more information:

```
bash run_test.h -t <test_ids> -k <kraken_db> -b <bowtie_db> -i <bowtie_index> -a <afanc_db> -r <resource_db>
        -t <test_ids>: string of of test IDs. These can be TM[01-10].     
                Multiple arguments can be supplied but they must each have the -t flag before     
                them e.g. -t TM01 -t TM02
        -d <data>: Directory containing test data. Default = s3://microbial-bioin-sp3/Lodestone_Testing_1.0/
        -k <kraken_db>: Kraken2 database directory. Default = <empty>
        -b <bowtie_db>: Bowtie database directory. Default = <empty>
        -i <bowtie_index>: Bowtie index prefix. Default = <empty>
        -a <afanc_db>: Afanc database directory. Default = <empty>
        -r <resource_db>: Resource directory. Default = <empty>
        -p <profile>: Nextflow profile. Default = climb

```

## Output
The test script will create a PDF file documenting the test results.