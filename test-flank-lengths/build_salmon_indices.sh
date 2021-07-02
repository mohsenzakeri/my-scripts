salmon="/mnt/scratch3/alevin_fry_submission/Benchmark-snRNAseq/rob-binaries/salmon"
top_dir="/mnt/scratch1/mohsen/salmon_indices"

ref_dir="/mnt/scratch3/mohsen/test-af-scripts/refs/refdata-gex-GRCh38-2020-A/"
extra_spliced_seqs="/mnt/scratch3/alevin_fry_submission/alevin-fry-paper-scripts/mito_seqs/homo_sapiens_mito.fa"
ref_name="human-2020A"
mkdir -p $ref_name

gtf_path="$ref_dir/genes/genes.gtf"
genome_path="$ref_dir/fasta/genome.fa"
threads=20
START=85
END=145

for ((i=START;i<=END;i=i+5)); do
	echo $i
	splici_dir="$top_dir/$ref_name/transcriptome_splici_fl$i/"
	mkdir -p $splici_dir
	cmd="Rscript build_splici_txome.R $gtf_path $genome_path $i $splici_dir $extra_spliced_seqs"
	echo $cmd
	eval $cmd
	fasta="$top_dir/$ref_name/transcriptome_splici_fl$i/transcriptome_splici_fl$i.fa"
	salmon_dir="$ref_name/salmon_fl${i}_index_sparse/"
	mkdir -p $salmon_dir
	cmd="/usr/bin/time -v -o $salmon_dir/index.time $salmon index -i $salmon_dir -t $fasta -p $threads --sparse"
	echo $cmd
	eval $cmd
done
