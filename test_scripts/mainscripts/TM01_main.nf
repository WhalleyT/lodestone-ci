#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl=2

// import subworkflows
include {tm01} from './../workflows/TM01.nf'

/*
 ANSI escape codes to allow colour-coded output messages
 This code is from https://github.com/angelovangel
 */

ANSI_GREEN = "\033[1;32m"
ANSI_RED   = "\033[1;31m"
ANSI_RESET = "\033[0m"

if (params.help) {
    helpMessage()
    exit(0)
}

def helpMessage() {
log.info """
========================================================================
TM01 TEST PIPELINE

Mandatory and conditional parameters:
------------------------------------------------------------------------
--input_dir           directory containing fastq OR bam files. Workflow will process one or the other, so don't mix
--filetype	      file type in input_dir. One of either "fastq" or "bam". fastq files can be gzipped and do not
                      have to literally take the form "*.fastq"; see --pattern
--pattern             regex to match files in input_dir, e.g. "*_R{1,2}.fq.gz". Only mandatory if --filetype is "fastq"
--output_dir          output directory, in which will be created subdirectories matching base name of fastq/bam files



Profiles:
------------------------------------------------------------------------
singularity        to run with singularity
docker		   to run with docker


Examples:
------------------------------------------------------------------------
nextflow run main.nf -profile singularity --filetype fastq --input_dir fq_dir --pattern "*_R{1,2}.fastq.gz" --unmix_myco yes --output_dir .
nextflow run main.nf -profile docker --filetype bam --input_dir bam_dir --unmix_myco yes --output_dir .
========================================================================
"""
.stripIndent()
}


// confirm that mandatory parameters have been set and that the conditional parameter, --pattern, has been used appropriately
if ( params.input_dir == "" ) {
    exit 1, "error: --input_dir is mandatory (run with --help to see parameters)"
}
if ( params.filetype == "" ) {
    exit 1, "error: --filetype is mandatory (run with --help to see parameters)"
}
if ( ( params.filetype == "fastq" ) && ( params.pattern == "" ) ) {
    exit 1, "error: --pattern is mandatory if you are providing fastq input; describes files in --input_dir (e.g. \"*_R{1,2}.fastq.gz\") (run with --help to see parameters)"
}
if ( ( params.filetype == "bam" ) && ( params.pattern != "" ) ) {
    exit 1, "error: --pattern should only be set if you are providing fastq input (run with --help to see parameters)"
}
if ( params.output_dir == "" ) {
    exit 1, "error: --output_dir is mandatory (run with --help to see parameters)"
}
if ( ( params.filetype != "fastq" ) && ( params.filetype != "bam" ) ) {
    exit 1, "error: --filetype is mandatory and must be either \"fastq\" or \"bam\""
}


log.info """
========================================================================
M Y C O B A C T E R I A L  P I P E L I N E

Parameters used:
------------------------------------------------------------------------
--input_dir		${params.input_dir}
--filetype		${params.filetype}
--pattern		${params.pattern}
--output_dir	        ${params.output_dir}

Runtime data:
------------------------------------------------------------------------
Running with profile  ${ANSI_GREEN}${workflow.profile}${ANSI_RESET}
Running as user       ${ANSI_GREEN}${workflow.userName}${ANSI_RESET}
Launch directory      ${ANSI_GREEN}${workflow.launchDir}${ANSI_RESET}
"""
.stripIndent()

// main workflow
workflow {

    // add a trailing slash if it was not originally provided to --input_dir
    inputdir_amended = "${params.input_dir}".replaceFirst(/$/, "/")

    indir = inputdir_amended
    numfiles = 0

    if ( params.filetype == "bam" ) {
        reads = indir + "*.bam"
        numfiles = file(reads) // count the number of files

        Channel.fromPath(reads)
               .set{ input_files }
    }

    if ( params.filetype == "fastq" ) {
        pattern = params.pattern
        reads = indir + pattern
        numfiles = file(reads) // count the number of files

        Channel.fromFilePairs(reads, flat: true, checkIfExists: true, size: -1)
	       .ifEmpty { error "cannot find any reads matching ${pattern} in ${indir}" }
	       .set{ input_files }
    }


    // call preprocressing subworkflow
    main:
      tm01(input_files)
}

workflow.onComplete {
    if ( workflow.success ) {
        log.info """
        ===========================================
        ${ANSI_GREEN}Workflow completed successfully
        """
        .stripIndent()
    }
    else {
        log.info """
        ===========================================
        ${ANSI_RED}Finished with errors${ANSI_RESET}
        """
        .stripIndent()
    }
}
