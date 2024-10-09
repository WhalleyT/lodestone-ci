// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {kraken2} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {afanc} from '../../lodestone/modules/preprocessingModules.nf' params(params)
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
      println(params.refseq)
      afanc(kraken2.out.kraken2_fqs.join(kraken2.out.kraken2_json, by: 0), params.afanc_myco_db, params.resource_dir, params.refseq)
      
      // TM04 START: bowtie2 takes reads unfiltered by the kraken2 process
      bowtie2(formatInput.out.inputfqs, bowtie_dir.toList())
      contamination_input = bowtie2.out.bowtie2_fqs.join(afanc.out.afanc_json).join(kraken2.out.kraken2_json, by:0)
      identifyBacterialContaminants(contamination_input, params.resource_dir, params.refseq, 1)
}
