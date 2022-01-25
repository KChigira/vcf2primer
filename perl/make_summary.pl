use strict;
use warnings;
use utf8;

my ($IN, $OUT);
my @tmp;
my $len;

my (@genotype, @depth);
my (@geno_a, @geno_b, @geno_c);
my @row = ();

if (@ARGV == 2){
  $IN = $ARGV[0];
  $OUT = $ARGV[1];
}else{
  die "2 argument is needed.\n";
}

open my $fh_in, '<', $IN
  or die "Can not open file : ${IN}\n";
open my $fh_out, '>', $OUT;

while(my $line = <$fh_in>){
  chomp($line);
  @tmp = split(/\t/, ${line});
  $len = @tmp;
  if($len < 11) {
    next;
  }
  @row = ();
  if($tmp[0] eq "#CHROM") {
    @row = ("chr","pos",$tmp[9],$tmp[10],
            "dp_".$tmp[9],"dp_".$tmp[10],);
  }else{
    push @row, ($tmp[0], $tmp[1]);
    #extract genotype and depth
    my @geno_format = split(/:/, $tmp[8]);
    my $formatlen = @geno_format;
    my @geno_a = split(/:/, $tmp[9]);
    my @geno_b = split(/:/, $tmp[10]);
    for (my $i = 0; $i < $formatlen; $i++){
      if($geno_format[$i] eq "GT"){
        @genotype = ($geno_a[$i], $geno_b[$i]);
      }elsif($geno_format[$i] eq "DP"){
        @depth = ($geno_a[$i], $geno_b[$i]);
      }
    }
    if($genotype[0] eq "0/0" && $genotype[1] eq "1/1"){
      push @row, ($tmp[3], $tmp[4]);
    }
    if($genotype[0] eq "1/1" && $genotype[1] eq "0/0"){
      push @row, ($tmp[4], $tmp[3]);
    }
    push @row, ($depth[0], $depth[1]);
  }
  print $fh_out join("\t", @row)."\n";
}

close $fh_in;
close $fh_out;
