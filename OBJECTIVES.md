# Objectives

Determine whether cross contamination can explain any of the admixed individuals in the `och_admixture_values.csv` file.

---

Don't modify this file.

---

## Source of Cross Contamination: Tissue Subsampling

cross contamination during tissue subsampling and extraction could result in a pattern where individuals appear admixed because of DNA carry over from one sample to the next.  

* the `och_extractions_only.xlsx` contains a notes column where potential cross contamination events were logged if detected by students in the lab.  

* The individuals (individual_id) were given their id as they were processed, so we can assume that the individuals were processed in numerical order based on the `individual_id`, `date_subsampling`, `subsampler` columns.  
	* assume that when sorting by date_subampling, subsampler, individual_id that cross contam was possible within the interaction of data_subsampling and subsampler.  
* We want to test for a non-random pattern in the occurence of admixed individuals with respect to tissue subsampling .  
	* More explicitly, is there a pattern of e.g. (1) pure, admixed, pure (model where dissection tools are cleaned every other individal), (2)  pure, admixed, less admixed, pure (model where dissection tools are cleaned every 3 inviduals), etc...

## Source of Cross Contamination: DNA Extraction
	
For extraction, again cross contam was possible

* sorting by date_extracting, tube_stuffer, and individual_id, cross contam was possible within the interaction of date_extacting and tube_stuffer.  

* We want to test for a non-random pattern in the occurence of admixed individuals with respect to extraction.  
	* More explicitly, is there a pattern of e.g. (1) pure, admixed, pure (model where dissection tools are cleaned every other individal), (2)  pure, admixed, less admixed, pure (model where dissection tools are cleaned every 3 inviduals), etc...

## Source of Cross Contamination: Transfer DNA extract to 96 well microplates

downstream, it might be possible that cross contamination occurred in transferring dna extract to the 96 well microplates.  

* Following extraction, dna was transferring into microplates. 
	* In `och_extractions_only.xlsx`, the `plateid` column is the parent or base name for all plates containing dna extract. 
	* the `elution[1234]_plateid` is the specific plate id for each elution from the silica membranes used for dna extraction. 
	* the `elution[1234]_column` and `elution[1234]_row` contain the well address for each extract (`extraction_id`).  
* We are interested in testing for a non-random pattern in the occurence of admixed individuals with respect to position in the extraction plate     
	* More explicitly, are wells with admixed invididuals more likely to be adjacent to wells with pure individuals from different groups than wells with pure individuals.

## Source of Cross Contamination: Library prep transfer to lib plate

cross contamination may occur during library construction when samples are transferred from the dna extract plates to the library plates, or due to pipetting errors that occur prior to pcr where the libraries are uniquely indexed.

* library construction is documented in `Och_SSLibrariesforCapture_metadata.xlsx`
	* the `Extraction_ID` and `Library_id` columns uniquely identify each row.
	* the dna extract plate names are in the 5th column (E) 'Sample Plate'
		* the positions of the dna in the dna extract plates are columns 6 (F) and 7 (G), `Sample Column` and `Sample Row`.
	* The samples are transferred from the dna extract plate to the library plate 
		* column AB, `Library Plate`
		* column Z, `Library plate col`
		* column AA, `Library plate row`

* We are interested in testing for a non-random pattern in the occurence of admixed individuals with respect to the position in the library plate.     
	* More explicitly, are wells with admixed invididuals more likely to be adjacent to wells with pure individuals from different groups than wells with pure individuals.
	

## Source of Cross Contamination: Library prep indexing

cross contamination may occur due to the assignment of the same indexes to different individuals within the same sequening pool or run.

* we employ illumina truseq with dual indexing.
	* each library within a sequencing run should have a unique combination of indexes
	* there were 3 sequencing runs for Och. These are documented in the `seq_reports` dir which contains the names of the sequences and some stats about the sequencing output.
		* test lane: `seq_reports/PIRE-Cha-Och-TestLane_SeqSummary.xlsx`
		* test lane 2: `seq_reports/PIRE_Och-TestLane2_SeqSummary.xlsx`
		* full lane: `seq_reports/PIRE-Adu-Och-Sde-Sin_December2024_SeqSummary.xlsx`

* pools of libraries would be 
	* first sequenced on a small "test lane" to help with balancing sequencing effort between libs
	* second sequenced on a larger "full lane" where libs would be rebalanced/normalized based on the representation of each library in the test lane

* library construction is documented in `Och_SSLibrariesforCapture_metadata.xlsx`
	* The indexes assigned to each library are documented
		* column AG, `i5 Primer`, the name of the i5 primer where each indexed primer has a different name
		* column AH, `i5 Index for Novogene`, the index sequence
		* column AI, `i7 Primer`, the i7 primer name where each indexed primer has a different name
		* column AJ, `i7 Index`, the index sequence
	* Inclusion of libraries in a test lane are documented in column BE `Pool for lcwgs test?`
	* The pool id for the test lanes are documented in column BF `TestLanePool`
		* a single sequencing run such as "test lane" could have multiple pools
	* The pooling of pools for a given sequencing round is documented in column BX `Pool Round`
		* Pools in the same Pool Round were sequenced together on the same lanes in the same run.
	* Inclusion of libraries in a full lane are documented in column CJ `Pool for full seq?`
	* The pool id for the full lanes are documented in column CL `Pool`
	* All pools were pooled into a single superpool for the full lane 
		* Test lanes and full lanes were sequenced separately
* We are interested in determining whether any libraries that were sequenced together had the same index combination.  

* We are interested in determining whether any libraries that were sequenced together had the same index combination.     

## Source of Cross Contamination: Library prep transfer to library dilution plate (normalization)

cross contamination should not occur during library construction when samples are transferred from the library plates to the library dilution plates, which are necessary when samples must be diluted to achieve the desired amount of DNA to be pooled per lib, because the DNA is already indexed at this point. A problem here might be related to something with the library contruction upstream.

* library construction is documented in `Och_SSLibrariesforCapture_metadata.xlsx`
	* The samples are transferred from the library plate to the library dilution plate 
	* the library dilution plate names are in column BP 'Dilution Plate'
		* the positions of the library in the library dilution plates are columns BQ and BR, `Dilution Plate Col` and `Dilution Plate Row`.

* We are interested in testing for a non-random pattern in the occurence of admixed individuals with respect to the position in the library dilution plate.     
	* More explicitly, are wells with admixed invididuals more likely to be adjacent to wells with pure individuals from different groups than wells with pure individuals.

## Source of Cross Contamination: Coding the Index Combinations for Sequencing

cross contamination may occur due to the assignment of the same sequence names to different individuals within the same sequening pool or run.

* we employ illumina truseq with dual indexing.
	* each library within a sequencing run should have a unique combination of indexes
	* each unique combination of indexes within a seq run should have a unique seq name
	* we gave the same libraries from the same individuals different seq names in the test lanes versus the full lanes

* library construction is documented in `Och_SSLibrariesforCapture_metadata.xlsx`
	* The seq names assigned to each library are documented
		* column CD, `Test Lane Seq Name`
			* the seq name assigned to a given library in the test lane seq run
			* This is not unique, it's a base name
		* column CE, `NovoGeneSeqID`
			* the seq name assigned to a given library in the test lane seq run
			* this is supposed to be unique and is composed of both the `Test Lane Seq Name` and the address of the well
			* If multiple individuals have the same seq name, this could cause reads from different libs to be assigned to the same seq name resulting in "cross contamination"
		* column CF, `Sequence_ID`, this is the PIRE sequence name which includes the extraction id, library id and seq run
			* example: Och-ACat_020-Ex1-8B-lcwgs-2-1
				* Och - species code
				* A - era (historical = A, contemporary = C)
				* Cat - location id
				* 020 - individual id within species, era, location
				* Ex1 - extraction id within species, era, location, individual
				* 8B - library well position
				* lcwgs - library type
				* 2 - library id within species, era, location, individual, extraction
				* 1 - seq run id within species, era, location, individual, extraction, library
		* column CM, `Full seq Name`
			* the seq name assigned to a given library in the full lane seq run
			* this is supposed to be unique 
			*  reads from different libs that are assigned to the same seq name would cause "cross contamination"
		* column CN, `Full seq decode`, this is the PIRE sequence name which includes the extraction id, library id and seq run
			* example: Och-ACat_020-Ex1-8B-lcwgs-2-2
				* Och - species code
				* A - era (historical = A, contemporary = C)
				* Cat - location id
				* 020 - individual id within species, era, location
				* Ex1 - extraction id within species, era, location, individual
				* 8B - library well position
				* lcwgs - library type
				* 2 - library id within species, era, location, individual, extraction
				* 2 - seq run id within species, era, location, individual, extraction, library

* We are interested in determining whether any libraries that were sequenced together had the same seq name. 

## Source of Cross Contamination: Decode Files 

cross contamination may occur due to errors in creating the sequencing decode files which associate the two sequencing names given to each library in each seq run.

* The decode files are in `*_sequencing_run/*/decode_sedlist.txt`
	* `1st` and `2nd_sequencing_run` dirs are the same libs and seqs ("test lane")
		* ignore `1st_sequencing_run` dir
		* test against metadata file `Och_SSLibrariesforCapture_metadata.xlsx`
			* libs (rows) differentiated by column BX `Pool Round` = "Test Lane"
			* compare first name col in decode file to column CE `NovoGeneSeqID`
			* compare second name col in decode file to column CF `Sequence_ID`
	* `3rd_sequencing_run` dir is "test lane 2"
		* test against metadata file `Och_SSLibrariesforCapture_metadata.xlsx`
			* libs (rows) differentiated by column BX `Pool Round` = "Test Lane 2"
			* compare first name col in decode file to column CE `NovoGeneSeqID`
			* compare second name col in decode file to column CF `Sequence_ID`
	* `4th_sequencing_run` dir is "full lane"
		* test against metadata file `Och_SSLibrariesforCapture_metadata.xlsx`
			* libs (rows) differentiated by column CJ `Pool for full seq?` = "Yes"
			* compare first name col in decode file to column CM `Full seq Name`
			* compare second name col in decode file to column CN `Full seq decode`
* We expect the file names and associations to be the same in the decode files and the metadata file.

## Source of Cross Contamination: GenErode Symlinks 

cross contamination may occur due to errors in creating the symlinks in the generode dir which associate multiple pairs of fastq files with the same seq id.

* The symlink files are in `generode_symlinks/`
	* these files contain the results of `ls -lh GenErode_Och_20k/data/raw_reads_symlinks/(historical|modern)/*gz > generode_hist_symlinks.txt` from the repo on the wahab hpc, not the present repo.
* We expect the individual ID in the link to match that in the original file name.
	* in the link name, the `_` and `-` have been removed
		* e.g. OchATum036
	* in the orginal file name, they have not been removed
		* e.g. Och-ATum_036

