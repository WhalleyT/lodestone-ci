# Lodestone Testing

## Aims
This repositry is designed to perform automated testing of [Lodestone](https://github.com/Pathogen-Genomics-Cymru/tb-pipeline) pipeline. It takes test datasets help in an [S3 bucket](https://s3.console.aws.amazon.com/s3/buckets/sp3testdata), downloads them along with the requisite Kraken2 and Bowtie databases and runs the nextflow pipeline against them based on changes to the module module files.

## Usage
This repo is primarily intended to be automated. However, the test scripts can still be ran as follows:

```"bash run_test.sh -t <test_ids>```

Where ```_test_ids``` refers to the test ID, ranging from TM01 to TM10. Multiple arguments can be supplied. Additional arguments can be supplied to point to the correct Kraken2 and Bowtie databases, as well to run the script with or without singularity. See ```bash run_test.sh -h``` for more information:

```
bash run_test.h -t <test_ids> -k <kraken_db> -b <bowtie_db> -i <bowtie_index>
	-t <test_ids>: string of of test IDs. These can be TM[01-10].
	-k <kraken_db>: Kraken2 database directory. Default = pluspf_16gb
	-b <bowtie_db>: Bowtie database directory. Default = hg19_1kgmaj
	-i <index>: Bowtie index prefix. Default = hg19_1kgmaj
```

## Output
The test script will create a PDF file documenting the test results.