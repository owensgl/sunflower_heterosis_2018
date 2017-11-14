# sunflower_heterosis_2018
Scripts for the paper "Genomics of hybrid crop development in sunflower: parallel evolution of male and female lines, except for divergence in sequence and copy-number associated with recent introgressions"

1. Calculating FST
* VCF files were first converted to a flat tab delimited format using <vcf2vertical_bi_basic.pl> then FST was calculate at each site using <SNPtable2Fst.pl> and summarized by window using <SlidingWindow_onlyfst.pl>
2. Quantifying copy number
* Average read depth per gene was calculating using samtools through the script <bam2countreadspergene.pl>
3. Simulating crosses
* Missing genes per simulated cross were calculated using <call_genecount.sh> and <simulate_indcrosses_missinggenes.pl>
4. Permutations of copy number variation
* The significance of the difference in PAV between groups was calculated using permutations of group identity with the <count_depth_freq_dif_permutation.pl> script

