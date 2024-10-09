// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {mykrobe} from '../../lodestone/modules/preprocessingModules.nf' params(params)
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
      // TM03 START
      mykrobe(formatInput.out.inputfqs)
}
