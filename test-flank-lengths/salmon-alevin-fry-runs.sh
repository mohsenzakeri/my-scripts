### binaries
salmon="/mnt/scratch3/alevin_fry_submission/Benchmark-snRNAseq/rob-binaries/salmon"
fry="/mnt/scratch3/alevin_fry_submission/Benchmark-snRNAseq/rob-binaries/alevin-fry"
time="/usr/bin/time -v -o"

### directories
unflist="/mnt/scratch2/mohsen/test-fry/10xv3permit.txt"
top_dir="/mnt/scratch1/mohsen/salmon_indices"
indices_dir="$top_dir/human-cr3"
out_dir="$top_dir/salmon_sim_data"
mkdir -p $out_dir
fastq_dir="/mnt/scratch1/alevin_fry_submission/samples/pbmc_5k_sims_human_CR_3.0.0_MultiGeneNo_rl91/"
read1=$(ls $fastq_dir | awk -v p=$fastq_dir '{print p$0}' | grep "R1") 
read2=$(ls $fastq_dir | awk -v p=$fastq_dir '{print p$0}' | grep "R2") 

### run-configurations
orientation="fw"
resolution="cr-like"
permitmode="unfilt"
permitmodecmd="-u $unflist"
permitlist="permitlist_$permitmode"
threads=20
version="chromiumV3"

START=85
END=145
for ((i=START;i<=END;i=i+5)); do

	out="$out_dir/salmon_fl${i}_sparse"
	mkdir -p $out_dir

	logdir="$out/logs"
	mkdir -p $logdir

	t2g="$indices_dir/transcriptome_splici_fl$i/transcriptome_splici_fl${i}_t2g_3col.tsv"
	index_dir="$indices_dir/salmon_fl${i}_index_sparse/"
	### mapping reads
	cmd="/usr/bin/time -v -o $out/logs/pseudoalignment.time $salmon alevin -l ISR -i $index_dir -1 $read1 -2 $read2 -o $out t -p $threads --$version  --rad --sketch"
	echo $cmd
	eval $cmd

	### generate permit list
	cmd="$time $logdir/$permitlist.time $fry generate-permit-list $permitmodecmd -d $orientation -i $out -o $out/$permitlist/"
	echo $cmd
	eval $cmd

	### collate
	cmd="$time $logdir/collate_$permitmode.time $fry collate -i $out/$permitlist/ -r $out -t $threads"
	echo $cmd
	eval $cmd
	
	### quant
	cmd="$time $logdir/quant_${permitmode}_$resolution.time $fry quant -r $resolution --use-mtx -m $t2g -i $out/$permitlist/ -o $out/quant_${permitmode}_$resolution -t $threads"
	echo $cmd
	eval $cmd
done
