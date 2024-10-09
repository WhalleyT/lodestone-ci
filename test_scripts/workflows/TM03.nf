// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {kraken2} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {afanc} from '../../lodestone/modules/preprocessingModules.nf' params(params)
include {formatInput} from "../../lodestone/modules/ciModules.nf" params(params)

/* TM05 test module
*/
workflow tm03 {

    take:
      input_files
      krakenDB
      bowtie_dir

    main:
      formatInput(input_files)
      kraken2(formatInput.out.inputfqs, krakenDB.toList())
      afanc(kraken2.out.kraken2_fqs.join(kraken2.out.kraken2_json, by: 0), params.afanc_myco_db, params.resource_dir, params.refseq)
}
