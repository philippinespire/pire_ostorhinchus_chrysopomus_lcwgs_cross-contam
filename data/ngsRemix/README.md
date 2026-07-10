# ngsRemix Results

This dir contains the output of ngsRemix, which determines relatedness in admixed populations.  

The file `ngsremix_fixed_k3` contains the kinship coefficients k0,k1,k2, which can be used to estimate relatedness.

The file `bam_list_all_fullpath.txt` contains the paths to the original bam files used to make the beagle file that was used to create the data for ngsremix.  Therefore, it has the names of the specimens, in order.

The file `k1_k2_and_total_relatedness_script_ceb.R` is an r script that reads in `ngsremix_fixed_k3`, the output of ngsremix, as well as `bam_list_all_fullpath.txt`.  The script adds the relevant data from the bam list to the ngsremix output (pop1, pop2, er1, era2, seqid1, seqid2).