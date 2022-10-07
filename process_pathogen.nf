#!/usr/bin/env nextflow


process pre_process {
    input:
        path fasta_file
        path metadata_file
        path tree_file
    output:
        path "preprocessed_${fasta_file}", emit: preprocessed_fasta
        path "preprocessed_${metadata_file}", emit: preprocessed_metadata
        path "preprocessed_${tree_file}", emit: preprocessed_tree, optional: true
    script:
    if (tree_file.isEmpty())
        """
        bash $params.work_dir/pre_process.sh $fasta_file $metadata_file
        """
    else
        """
        bash $params.work_dir/pre_process.sh $fasta_file $metadata_file $tree_file
        """
    stub:
    if (tree_file.isEmpty())
        """
        touch preprocessed_$fasta_file
        touch preprocessed_$metadata_file
        touch preprocessed_$tree_file
        echo "$params.work_dir/pre_process.sh $fasta_file $metadata_file $tree_file"
        """
}

process basic_checks {
    input:
        path fasta_file
        path metadata_file
        path tree_file
    script:
        """
        basic_checks.py $fasta_file $metadata_file $tree_file
        """
    stub:
        """
        echo "basic_checks.py $fasta_file $metadata_file $tree_file"
        """
}

process align {
    label 'minimap2'
    input:
        path fasta
        path ref_seq
    output:
        path "aligned.fasta", emit: aligned_fasta_file
    script:
    if (params.align_mode == 'mafft')
        if (ref_seq.isEmpty())
            """
            mafft --auto --thread $params.threads $fasta > aligned.fasta
            """
        else
            """
            mafft --auto --thread $params.threads --addfragments $fasta $ref_seq > aligned.fasta
            """
    else if( params.align_mode == 'minimap2' )
        """
        minimap2 -a $ref_seq $fasta | gofasta sam toMultiAlign  > aligned.fasta
        """
    stub:
        """
        touch aligned.fasta
        echo "Stubbed alignment of $fasta"
        """
}

process build_ml_tree {
    input:
        path aligned_fasta
    output:
        path "ml_tree.treefile", emit: tree_file
    script:
        """
        iqtree2 -s $aligned_fasta -T $params.threads -m $params.iqtree_nucleotide_model --prefix ml_tree
        """
    stub:
        """
        touch ml_tree.treefile
        echo "Stubbed ML tree building of $aligned_fasta"
        """
}

process clock_filter {
    input:
        path aligned_fasta
        path tree
        path metadata_file
    output:
        path "clock_results/timetree.nexus", emit: filtered_tree_file
        path 'clock_results/*'
    script:
        """
        treetime --aln $aligned_fasta --tree $tree --dates $metadata_file --name-column $params.strain_column --date-column $params.date_column --clock-filter $params.clock_filter --outdir clock_results
        """
        // treetime --tree $tree --dates $params.metadata_file --aln $aligned_fasta --outdir timetree
        // Note: This outputs the tree in NEXUS format, which is not supported by the next process.
    stub:
        """
        mkdir clock_results
        touch clock_results/timetree.nexus
        echo "Stubbed clock filter of $aligned_fasta"
        """
}

// Convert nexus to newick
// Note: Not in use.
process convert_nexus_to_newick {
    label 'phyclip'
    input:
        path nexus_tree
    output:
        path 'timetree.newick', emit: newick_tree_file
    script:
        """
        convert_nexus_to_newick.py -i $nexus_tree -o timetree.newick -r
        """
    stub:
        """
        touch timetree.newick
        echo "Stubbed nexus to newick conversion of $nexus_tree"
        """
}

process entropy {
    input:
        path aligned_fasta
    output:
        path 'entropy.pdf'
    script:
        """
        entropy.py $aligned_fasta
        """
    stub:
        """
        touch entropy.pdf
        echo "Stubbed entropy calculation of $aligned_fasta"
        """
}

process generate_vcf {
    label 'usher'
    input:
        path aligned_fasta
    output:
        path 'aligned.vcf', emit: vcf_file
    script:
        """
        faToVcf $aligned_fasta aligned.vcf
        """
    stub:
        """
        touch aligned.vcf
        echo "Stubbed vcf generation of $aligned_fasta"
        """
}

process generate_protobuf_tree {
    label 'usher'
    input:
        path vcf
        path tree
    output:
        path 'tree.pb', emit: protobuf_tree_file
    script:
        """
        usher -t $tree -v $vcf -o tree.pb -T $params.threads
        """
    stub:
        """
        touch tree.pb
        echo "Stubbed protobuf tree generation of $vcf"
        """
}

process get_clades {
    label 'phyclip'
    debug true
    input:
        // This has been added so nexflow will create a symlink to the tree in the same work dir.
        path rerooted_tree
        path phyclip_input
    output:
        path 'cluster_optimal_parameter_*.txt', emit: clades_file
    script:
        """
        phyclip.py --input_file $phyclip_input --collapse_zero_branch_length 1 --subsume_subclusters 1 --optimise intermediate --threads $params.threads
        """
    stub:
        """
        touch cluster_1.txt
        touch cluster_2.txt
        touch cluster_3.txt
        touch cluster_4.txt
        echo "Stubbed phyclip of $phyclip_input"
        """
}

process generate_clade_tsv {
    input:
        path metadata_file
    output:
        path 'clade_assignments.tsv', emit: clade_tsv_file
    script:
        """
        generate_clade_tsv.py -i $metadata_file -s $params.strain_column -l $params.lineage_column -o clade_assignments.tsv
        """
    stub:
        """
        touch clade_assignments.tsv
        echo "Stubbed clade tsv generation of $metadata_file"
        """
}

process clean_clades_file {
    input:
        path clades_file
    output:
        path 'clade_assignments.tsv', emit: cleaned_clades_file
    script:
        """
        clean_clade_assignments.py $clades_file
        """
    stub:
        """
        touch clade_assignments.tsv
        echo "Stubbed cleaning of $clades_file"
        """
}

process annotate_tree {
    label 'usher'
    input:
        path protobuf_tree
        path cleaned_clades_file
    output:
        path 'annotated_tree.pb', emit: annotated_tree_file
    script:
        """
        matUtils annotate -i $protobuf_tree -c $cleaned_clades_file -o annotated_tree.pb
        """
    stub:
        """
        touch annotated_tree.pb
        echo "Stubbed annotation of $protobuf_tree"
        """
}

process extract_clades {
    label 'usher'
    input:
        path annotated_tree
    output:
        path 'lineagePaths.txt', emit: clade_assignments_file
    script:
        """
        matUtils extract -i $annotated_tree -C lineagePaths.txt
        """
    stub:
        """
        touch lineagePaths.txt
        echo "Stubbed clade extraction of $annotated_tree"
        """
}

process generate_barcodes {
    input:
        path clade_assignments_file
    output:
        path 'barcode.csv'
        path 'barcode.html'
    script:
        """
        convert_barcodes.py $clade_assignments_file
        plot_barcode.py
        """
    stub:
        """
        touch barcode.csv
        touch barcode.html
        echo "Stubbed barcode generation of $clade_assignments_file"
        """
}

// Note: This is to test the pipeline.
// Note: Do not include in actual workflow.
process python_version {
    script:
        """
        pyv.py
        """
    stub:
        """
        echo "Python version: 3.8.5"
        """
}

// TODO-GP: Modify the worflow to run all the processses.
workflow {
    // Print the input parameters
    println "Input parameters:"
    println "\tFasta file:\t${params.fasta_file}"
    println "\tWork directory:\t${params.work_dir}"
    println "tree_file.isEmpty(): ${params.tree_file.isEmpty()}"
    if (!params.skip_clade_annotations) {
        // Note: fasta and metadata files are required.
        pre_process(params.fasta_file, params.metadata_file. params.tree_file)
        basic_checks(pre_process.out.preprocessed_fasta, pre_process.out.preprocessed_metadata, pre_process.out.preprocessed_tree)
        align(pre_process.out.preprocessed_fasta, params.reference)
        build_ml_tree(align.out.aligned_fasta_file)
        clock_filter(align.out.aligned_fasta_file, build_ml_tree.out.tree_file, pre_process.out.preprocessed_metadata)
        generate_vcf(align.out.aligned_fasta_file)
        entropy(align.out.aligned_fasta_file)
        convert_nexus_to_newick(clock_filter.out.filtered_tree_file)
        generate_protobuf_tree(generate_vcf.out.vcf_file, convert_nexus_to_newick.out.newick_tree_file)
        get_clades(convert_nexus_to_newick.out.newick_tree_file, params.phyclip_input)
        clean_clades_file(get_clades.out.clades_file)
        annotate_tree(generate_protobuf_tree.out.protobuf_tree_file, clean_clades_file.out.cleaned_clades_file)
        extract_clades(annotate_tree.out.annotated_tree_file)
        generate_barcodes(extract_clades.out.clade_assignments_file)
    }
    else {
        // Note: tree, fasta and metadata files are required.
        println "__Skipping clade annotations.__"
        println "\tTree file:\t${params.tree_file}"
        println "\tMetadata file:\t${params.metadata_file}"
        pre_process(params.fasta_file, params.metadata_file, params.tree_file)
        basic_checks(pre_process.out.preprocessed_fasta, pre_process.out.preprocessed_metadata, pre_process.out.preprocessed_tree)
        if (pre_process.out.preprocessed_fasta.getName().contains("aligned")) {
            println "__Fasta file is already aligned.__"
            generate_vcf(pre_process.out.preprocessed_fasta)
        }
        else {
            println "__Aligning fasta file.__"
            align(pre_process.out.preprocessed_fasta, params.reference)
            generate_vcf(align.out.aligned_fasta_file)
        }
        generate_protobuf_tree(generate_vcf.out.vcf_file, params.tree_file)
        generate_clade_tsv(params.metadata_file)
        annotate_tree(generate_protobuf_tree.out.protobuf_tree_file, generate_clade_tsv.out.clade_tsv_file)
        extract_clades(annotate_tree.out.annotated_tree_file)
        generate_barcodes(extract_clades.out.clade_assignments_file)
    }
}

workflow.onComplete {
    println "Workflow complete!"
    println "Output files are stored in $params.work_dir/output"
}