#!/bin/perl
use strict;
use warnings;

#This script will take a list of genes in a gff3 file, and a bam files with sample ID, and count the number of reads in each genes for each sample. It also averages the number of reads per bp.
my $gff3 = $ARGV[0];
my $filelist = $ARGV[1];
#Filelist is formatted with samplename\tbamfile;
#May have multiple bam files per sample;

open GFF3, $gff3;

#For Cedar
my @genes_list;
my %genes_start;
my %genes_end;
my %genes_chr;
while(<GFF3>) {
  chomp;
  if ($_ =~ m/^#/){
    next;
  }
  my @a = split(/\t/,$_);
  my $chr = $a[0];
  my $type = $a[2];
  my $start = $a[3];
  my $end = $a[4];
  if ($type ne "gene"){
    next;
  }
  my @info = split(/;/,$a[8]);
  my $name = $info[0];
  $name =~ s/ID=gene://;
  push(@genes_list,$name);
  $genes_start{$name}= $start;
  $genes_end{$name} = $end;
  $genes_chr{$name} = $chr;
}

open FILELIST, $filelist;
my %samples;
while(<FILELIST>){
  chomp;
  my @a = split(/\t/,$_);
  my $name = $a[0];
  my $bam= $a[1];
  $samples{$name}{$bam}++;
}
print "sample\tgene\tchr\tstart\tend\tlength\traw_depth\tMQ1_depth\tMQ20_depth";
#Now query each bam file and sum the number of reads
foreach my $sample (sort keys %samples){
  foreach my $gene (@genes_list){
    my $length = $genes_end{$gene} - $genes_start{$gene};
    my $raw_depth_total = 0;
    my $q1_depth_total = 0;
    my $q20_depth_total = 0;
    my $bam_counter = 0;
    foreach my $bam (sort keys %{$samples{$sample}}){
      $bam_counter++;
      my $raw_depth=`samtools depth $bam -r  $genes_chr{$gene}:$genes_start{$gene}-$genes_end{$gene}   | awk '{ sum += \$3; n++ } END { if (n > 0) print sum / n; }'`;
      my $q1_depth=`samtools depth $bam -r  $genes_chr{$gene}:$genes_start{$gene}-$genes_end{$gene} -Q 1 | awk '{ sum += \$3; n++ } END { if (n > 0) print sum / n; }'`;
      my $q20_depth=`samtools depth $bam -r  $genes_chr{$gene}:$genes_start{$gene}-$genes_end{$gene}  -Q 20 | awk '{ sum += \$3; n++ } END { if (n > 0) print sum / n; }'`;
#      print "samtools depth $bam -r  $genes_chr{$gene}:$genes_start{$gene}-$genes_end{$gene} | awk '{ sum += \$3; n++ } END { if (n > 0) print sum / n; }\n";
      unless($raw_depth){
        $raw_depth = 0;
      }
      unless($q1_depth){
        $q1_depth = 0;
      }
      unless($q20_depth){
        $q20_depth = 0;
      }
      $raw_depth_total+=$raw_depth;
      $q1_depth_total+=$q1_depth;
      $q20_depth_total+=$q20_depth;
    }
    my $mean_raw_depth = $raw_depth_total/$bam_counter;
    my $mean_q1_depth = $q1_depth_total/$bam_counter;
    my $mean_q20_depth = $q20_depth_total/$bam_counter;
    print "\n$sample\t$gene\t$genes_chr{$gene}\t$genes_start{$gene}\t";
    print "$genes_end{$gene}\t$length\t$mean_raw_depth\t$mean_q1_depth\t$mean_q20_depth";
  }

}
