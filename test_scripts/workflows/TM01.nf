// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {checkFqValidity} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {countReads} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {fastp} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {fastQC} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {checkBamValidity} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {bam2fastq} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {getversion} from '../../lodestone/modules/getversionModules.nf' params(params)


// define workflow component
workflow tm01 {

    take:
      input_files
      
    main:
    
    getversion()
    input_files_vjson = input_files.combine(getversion.out.getversion_json)

      if ( params.filetype == "bam" ) {

          checkBamValidity(input_files_vjson)

          bam2fastq(checkBamValidity.out.checkValidity_bam)

          countReads(bam2fastq.out.bam2fastq_fqs)
      }

      if ( params.filetype == "fastq" ) {

          checkFqValidity(input_files_vjson)

          countReads(checkFqValidity.out.checkValidity_fqs)
      }

      fastp(countReads.out.countReads_fqs)

      fastQC(fastp.out.fastp_fqs)

}
