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
include {formatInput} from "../../modules/ciModules.nf" params(params)

/* TM05 test module
*/
workflow tm08 {

    take:
      input_files
      krakenDB
      bowtie_dir

    main:
      formatInput(input_files)
      kraken2(formatInput.out.inputfqs, krakenDB.toList())
      mykrobe(kraken2.out.kraken2_fqs)
      bowtie2(formatInput.out.inputfqs, bowtie_dir.toList())
      identifyBacterialContaminants(mykrobe.out.mykrobe_report.join(kraken2.out.kraken2_report, by: 0))
      downloadContamGenomes(identifyBacterialContaminants.out.contam_list)
      mapToContamFa(bowtie2.out.bowtie2_fqs.join(downloadContamGenomes.out.contam_fa, by: 0))
      reKraken(mapToContamFa.out.reClassification_fqs, krakenDB.toList())
      reMykrobe(mapToContamFa.out.reClassification_fqs)
      // TM08 START
      summarise(reMykrobe.out.reMykrobe_report.join(reKraken.out.reKraken_report, by: 0).join(identifyBacterialContaminants.out.prev_sample_json, by: 0))

}