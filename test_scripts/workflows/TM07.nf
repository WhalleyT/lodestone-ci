// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {checkFqValidity} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {countReads} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {fastp} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {fastQC} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {kraken2} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {mykrobe} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {bowtie2} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {identifyBacterialContaminants} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {downloadContamGenomes} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {mapToContamFa} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {reKraken} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {reMykrobe} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {summarise} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {checkBamValidity} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {bam2fastq} from '../../lodestone/modules/preprocessingModules.nf' params(params)

/* TM05 test module
*/
workflow tm07 {

    take:
      input_files
      krakenDB
      bowtie_dir

    main:
      // TM03 START
      reMykrobe(input_files)
}
