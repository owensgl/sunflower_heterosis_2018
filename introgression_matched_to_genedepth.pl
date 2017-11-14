#!/bin/perl
use warnings;
use strict;

#This takes a list of read depth information for genes in a file. It also takes a list of introgressed regions. This is designed for checking if missing genes in HA412 are in introgressed regions.


#Pipe in all the introgressed regions and load them up.

#results_ss_introgression.txt files for each chromosome
my $target_sample = "12"; #The number of the sample to look at.
my $genecount_file = $ARGV[0];
my %data;
my %start;
my %end;
my %group;
my %percent;
my $counter = 1;
while(<STDIN>){
  chomp;
  if ($_ =~ m/^sample/){
    next;
  }
  my @a = split(/\t/,$_);
  my $sample = $a[0];
  if ($sample != $target_sample){next;}
  my $chr = $a[1];
  my $start = $a[3];
  my $end = $a[4];
  my $group = $a[7];
  my $percent = $a[8];
  push(@{$data{$chr}},$counter);
  $start{$counter} = $start;
  $end{$counter} = $end;
  $group{$counter} = $group;
  $percent{$counter} = $percent;
  $counter++;
  
}
open GENE, $genecount_file;
print "sample\tchr\tgene\tstart\tend\traw_depth\tgroup\tpercent_intro";
while(<GENE>){
  chomp;
  if ($. == 1){next;}
  my @a = split(/\t/,$_);
  my $sample = $a[0];
  my $gene = $a[1];
  my $chr = $a[2];
  $chr =~ s/HanXRQChr//g;
  my $start = $a[3];
  my $end = $a[4];
  my $depth = $a[6];
  if (($chr =~ m/00/) or ($chr =~ m/CP/) or ($chr =~ m/MT/)){next;}
  my $best_group = "0";
  my $best_percent = "0";
  foreach my $i (@{$data{$chr}}){
    if ((($start{$i} <= $end) and ($end{$i} >= $end)) or (($start{$i} <= $start) and ($end{$i} >= $start))){
        if ($percent{$i} > $best_percent){
          $best_percent = $percent{$i};
          $best_group = $group{$i};
        }
    }
  }
  print "\n$sample\t$gene\t$chr\t$start\t$end\t$depth\t$best_group\t$best_percent";
}
