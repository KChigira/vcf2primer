use strict;
use warnings;
use utf8;

my ($IN, $OUT);
my $name;
my $line;
my @tmp;
my $scope;

my $chr;
my $ref_len;
my $start;
my $end;

if (@ARGV == 3){
  $IN = $ARGV[0];
  $OUT = $ARGV[1];
  $scope = $ARGV[2];
}else{
  print "3 arguments are needed.\n";
  exit(1);
}

open my $fh_in, '<', $IN
  or die "Can not open file ${IN}.";
open my $fh_out, '>', $OUT;

while($line = <$fh_in>){
  if(substr($line,0,1) eq "#"){
    next;
  }

  chomp($line);
  @tmp = split(/\t/, $line);
  $chr = $tmp[0];
  $ref_len = length $tmp[3];
  $start = $tmp[1] - $scope;
  $end = $tmp[1] + ($ref_len - 1) + $scope;
  print $fh_out "${chr}:${start}-${end}\n";
}

close $fh_in;
close $fh_out;

print "List for samtools has been generated.\n";
