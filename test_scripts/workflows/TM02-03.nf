// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {checkFqValidity} from '../../modules/preprocessingModules.nf' params(params)
include {countReads} from '../../modules/preprocessingModules.nf' params(params)
include {fastp} from '../../modules/preprocessingModules.nf' params(params)
include {fastQC} from '../../modules/preprocessingModules.nf' params(params)
include {kraken2} from '../../modules/preprocessingModules.nf' params(params)
include {mykrobe} from '../../modules/preprocessingModules.nf' params(params)
include {bowtie2} from '../../modules/preprocessingModules.nf' params(params)
include {identifyBacterialContaminants} from '../../modules/preprocessingModules.nf' params(params)
include {downloadContamGenomes} from '../../modules/preprocessingModules.nf' params(params)
include {mapToContamFa} from '../../modules/preprocessingModules.nf' params(params)
include {reKraken} from '../../modules/preprocessingModules.nf' params(params)
include {reMykrobe} from '../../modules/preprocessingModules.nf' params(params)
include {summarise} from '../../modules/preprocessingModules.nf' params(params)
include {checkBamValidity} from '../../modules/preprocessingModules.nf' params(params)
include {bam2fastq} from '../../modules/preprocessingModules.nf' params(params)
include {formatInput} from "../../modules/ciModules.nf" params(params)

// testing module for TM02 and TM03
workflow tm02 {

    take:
      input_files
      krakenDB
      bowtie_dir

    main:
      formatInput(input_files)
      // TM02 START
      kraken2(formatinput.out.inputfqs, krakenDB.toList())
      // TM03 START
      mykrobe(kraken2.out.kraken2_fqs)
}
