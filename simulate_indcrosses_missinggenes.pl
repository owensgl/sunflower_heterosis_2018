#!/bin/perl
use warnings;
use strict;

#This simulates crosses between and within groups at the individual level. It requires piping in all the genecount files and including an info file with sample group;
my $infofile = $ARGV[0]; #poplist.txt
my $nreps = 1000;
my %group;
my %group_list;
my %group_array;
open INFO, $infofile;
while(<INFO>){
  chomp;
  my @a = split(/\t/,$_);
  my $sample = $a[0];
  $sample =~ s/PPN/SAM/g;
  my $group = $a[1];
  $group{$sample} = $group;
  $group_list{$group}++;
}
my @groups = sort keys %group_list;
my %data;
my %gene_list;
my $previous_sample = "NA";
while(<STDIN>){
  chomp;
  if ($_ =~ m/^sample/){next;}
  my @a = split(/\t/,$_);
  my $sample = $a[0];
  unless ($group{$sample}){next;}
  if ($sample ne $previous_sample){
    push(@{$group_array{$group{$sample}}},$sample);
    $previous_sample = $sample;
    print STDERR "\nCollecting data for $sample";
  }
  my $gene = $a[1];
  my $chr = $a[2];
  if ($chr =~ m/HanXRQCP/){next;}
  if ($chr =~ m/HanXRQMT/){next;}
  if ($chr =~ m/HanXRQChr00/){next;}
  $gene_list{$gene}++;
  my $class = "1";
  if ($a[6] == 0){
    $class = "0";
  }
  $data{$sample}{$gene} = $class;
}
print STDERR "\nRunning simulations";
print "ind_comparison\tmissing_genes";
foreach my $i (0..$#groups){
  foreach my $j ($i..$#groups){
    print STDERR "\nRunning simulations for $groups[$i]-$groups[$j]";
    foreach my $rep (1..$nreps){
      my $num_i = @{$group_array{$groups[$i]}};
      my $i_n = int(rand($num_i));
      my $num_j = @{$group_array{$groups[$j]}};
      my $j_n = int(rand($num_j));
      until ($j_n != $i_n){
        $j_n = int(rand($num_j));
      }
      my $i_sample = $group_array{$groups[$i]}[$i_n];
      my $j_sample = $group_array{$groups[$j]}[$j_n];
      my $missing_genes = 0;
      foreach my $gene (sort keys %gene_list){
        my $sum_genes = $data{$i_sample}{$gene} + $data{$j_sample}{$gene};
        if ($sum_genes == 0){
          $missing_genes++;
        }
      }
      print "\n$groups[$i]-$groups[$j]\t$missing_genes";
    }
  }
}




