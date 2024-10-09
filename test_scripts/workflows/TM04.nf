// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {kraken2} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {mykrobe} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {bowtie2} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {identifyBacterialContaminants} from '../../lodestone/modules/decontaminationModules.nf' params(params)
include {formatInput} from '../../lodestone/modules/ciModules.nf' params(params)
/*
this currently maps unfiltered reads to bowtieDB, rather that filtered reads coming out of kraken2
*/
workflow tm04 {

    take:
      input_files
      krakenDB
      bowtie_dir

    main:
      formatInput(input_files)
      // kraken2 takes reads not subjected to QC
      // following block needed to create files necessary for TM04
      kraken2(formatInput.out.inputfqs, krakenDB.toList())
      mykrobe(kraken2.out.kraken2_fqs)

      // TM04 START: bowtie2 takes reads unfiltered by the kraken2 process
      bowtie2(formatInput.out.inputfqs, bowtie_dir.toList())
      identifyBacterialContaminants(mykrobe.out.mykrobe_report.join(kraken2.out.kraken2_report, by: 0), params.resource_dir, params.refseq, 1)
}
