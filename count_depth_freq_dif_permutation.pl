#!/bin/perl
use warnings;
use strict;
use Statistics::Basic qw(:all nofill);
#This script takes a single stream of genedepth files, loads them up, calculates the median depth, classifies things as missing, normal or duplicated, then calculates frequency of each per population
#For heterosis paper
my $max_normal_depth = 3;
my @comparison_groups = qw(HA RHA); #The two groups you want to get the difference of
my $infofile = $ARGV[0]; #poplist.txt

my %group;
my %group_list;
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

my %depths;
my %data;
my %gene_start;
my %gene_end;
my %gene_length;
my %gene_chr;
my %gene_list;
while(<STDIN>){
  chomp;
  if ($_ =~ m/^sample/){next;}
  my @a = split(/\t/,$_);
  my $sample = $a[0];
  unless ($group{$sample}){next;}
  my $gene = $a[1];
  my $chr = $a[2];
  if ($chr =~ m/HanXRQCP/){next;}
  if ($chr =~ m/HanXRQMT/){next;}
  if ($chr =~ m/HanXRQChr00/){next;}
  my $start = $a[3];
  my $end = $a[4];
  my $length = $a[5];
  $gene_list{$gene}++;
  $gene_chr{$gene} = $chr;
  $gene_start{$gene} = $start;
  $gene_end{$gene} = $end;
  $gene_length{$gene} = $length;
  my $depth = $a[6]; #Change this to use more filtered reads
  push(@{$depths{$sample}},$depth);
  $data{$sample}{$gene} = $depth;
  
}
my %class;
my %group_class;
foreach my $sample (sort keys %data){
  my $median_depth = median(@{$depths{$sample}});
  foreach my $gene (sort keys %{$data{$sample}}){
    my $comparative_depth = $data{$sample}{$gene}/ $median_depth;
    if ($data{$sample}{$gene} == 0){
      $class{$sample}{$gene} = 0;
    }elsif($comparative_depth > $max_normal_depth){
      $class{$sample}{$gene} = 2;
    }else{
      $class{$sample}{$gene} = 1;
    }
    $group_class{$group{$sample}}{$gene}{$class{$sample}{$gene}}++;
  }
}
print "class\tcomparison\tpercent_dif";
foreach my $gene (sort keys %gene_list){
  my %percentage;
  #Print out the percent of each 
  foreach my $group (sort keys %group_list){
    my $total_size;
    foreach my $class (0..2){
      unless($group_class{$group}{$gene}{$class}){
        $group_class{$group}{$gene}{$class} = 0;
      }
      $total_size+= $group_class{$group}{$gene}{$class};
    }
    foreach my $class (0..2){
      $percentage{$group}{$class} = $group_class{$group}{$gene}{$class} / $total_size;
    }
    
  }
  foreach my $class (0..2){
    my $dif = $percentage{$comparison_groups[0]}{$class} - $percentage{$comparison_groups[1]}{$class};
    print "\n$class\t$comparison_groups[0]-$comparison_groups[1]\t$dif";
  }
}
