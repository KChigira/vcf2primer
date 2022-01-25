use strict;
use warnings;
use utf8;

my $line;
my $id;
my $seq;
my $template;
my $scope;
my $margin;
my $OUT;

my $nrow = 0;
my $target_start;
my $target_length;

if (@ARGV == 6){
  $id = $ARGV[0];
  $seq = $ARGV[1];
  $template = $ARGV[2];
  $scope = $ARGV[3];
  $margin = $ARGV[4];
  $OUT = $ARGV[5];
}else{
  print "6 arguments are needed.\n";
  exit(1);
}

open my $fh_in, '<', ${template}
  or die "Can not open file";
open my $fh_out, '>', ${OUT};

#caliculate target sequence start position and length
$target_start = $scope - $margin + 1;
$target_length = (length $seq) - ($scope * 2) + ($margin * 2);

while($line = <$fh_in>){
  $nrow = $nrow + 1;
  chomp($line);

  if($nrow == 1){
    print $fh_out "${line}${id}\n";
  }elsif($nrow == 2){
    print $fh_out "${line}${seq}\n";
  }elsif($nrow == 3){
    print $fh_out "${line}${target_start},${target_length}\n";
#print substr($seq,$target_start-1,$target_length)."\n";
  }else{
    print $fh_out "${line}\n";
  }
}

close $fh_in;
close $fh_out;
