#!/usr/bin/perl -w 
use strict;
use warnings;
use File::Basename;

=head1
# this script is for modifying the germline vcf file from mouse sanger source
# author: laojp
# time: 2023.04.07
# position: SYSUCC bioinformatic platform
# usage: perl mouse_sanger_germline.pl [input snp.gz file] [input indel.gz file] [mouse line] [output snp.vcf file] [output indel.vcf file]
# ps: only for mouse sanger germline variation file
#
# update: will considerate the transferation from grcm38 to mm10 [format] 
# update: will considerate the combination of different part of ncbi dbsnp file [ncbi dbsnp file]
=cut

# judge the parameter is exist or not
my $vcf_file = shift or die "Please input the vcf file \n $!";
my $indel_file = shift or die "Please input the indel file \n $!";
my $mouse_line = shift or die "Please refer the mouse line \n $!";
my $out_file = shift or die "Please refer the output file \n $!";
my $out_indel = shift or die "Please refer the output indel file \n $!";
my $script_dir = dirname(__FILE__);

# read file --- outputhead --- filter the PASS and choose the mouse line --- zip and create index
sub modify_vcf {
	my %header;
	open(VCF, "-|", "gunzip -c $_[0]") or die "$!";
	open(OUT, ">", $_[1]) or die "$!";
	while(<VCF>){
		chomp;
		if($_ =~ /^#CHROM/){
			my @F = split(/\t/, $_);
			for(0..$#F){
				$header{$F[$_]} = $_;
			}
			print OUT "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t${mouse_line}\n";
			last;
		}
		if($_ =~ /^#/){
			print OUT "$_\n";
		}
	}
	while(<VCF>){
		chomp;
		my @F = split(/\t/, $_);
		my @G = split(/:/, $F[$header{"$mouse_line"}]);
		if($F[$header{"FILTER"}] eq "PASS" && $G[0] ne './.'){
			my $output = join("\t", $F[$header{"#CHROM"}], $F[$header{"POS"}], $F[$header{"ID"}], $F[$header{"REF"}], $F[$header{"ALT"}], $F[$header{"QUAL"}], $F[$header{"FILTER"}], $F[$header{"INFO"}], $F[$header{"FORMAT"}], $F[$header{"$mouse_line"}]);	
			print OUT "$output\n";
		}
	close(VCF);
	close(OUT);	
}

modify_vcf($vcf_file, $out_file) 
modify_vcf($indel_file, $out_indel)

system("bash ${script_dir}/mouse_sanger_germline_next.sh ${out_file}")
system("bash ${script_dir}/mouse_sanger_germline_next.sh ${out_indel}")
