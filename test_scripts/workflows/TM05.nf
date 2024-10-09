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
include {formatInput} from '../../modules/'
/* TM05 test module
*/
workflow tm05 {

    take:
      input_files
      krakenDB
      bowtie_dir

    main:
      formatInput(input_files)
      // kraken2 takes reads not subjected to QC
      // following block needed to create files necessary for TM05
      kraken2(formatInput.out.inputfqs, krakenDB.toList())
      mykrobe(kraken2.out.kraken2_fqs)
      bowtie2(formatInput.out.inputfqs, bowtie_dir.toList())
      identifyBacterialContaminants(mykrobe.out.mykrobe_report.join(kraken2.out.kraken2_report, by: 0))

      // TM05 START
      downloadContamGenomes(identifyBacterialContaminants.out.contam_list)
      mapToContamFa(bowtie2.out.bowtie2_fqs.join(downloadContamGenomes.out.contam_fa, by: 0))
}
