use strict;
use warnings;
use utf8;

my ($IN, $OUT);
my $is_newfile = 0;
my @tmp;
my $len;

my @output = ();

if (@ARGV == 2){
  $IN = $ARGV[0];
  $OUT = $ARGV[1];
}else{
  die "2 argument is needed.\n";
}

if(!(-f $OUT)){
  $is_newfile = 1;
}

open my $fh_in, '<', $IN
  or die "Can not open file\n";
open my $fh_out, '>>', $OUT;

if($is_newfile){
  print $fh_out "ID\tLEFT_SEQ\tRIGHT_SEQ\tL_POS_LEN\tR_POS_LEN\t".
                "L_TM\tR_TM\tPRODUCT_LEN\n";
}

while(my $line = <$fh_in>){
  chomp($line);
  @tmp = split(/=/, ${line});
  $len = @tmp;
  if($len < 2) {
    next;
  }
  if(($tmp[0] eq "SEQUENCE_ID") ||
     ($tmp[0] eq "PRIMER_LEFT_0_SEQUENCE") ||
     ($tmp[0] eq "PRIMER_RIGHT_0_SEQUENCE") ||
     ($tmp[0] eq "PRIMER_LEFT_0") ||
     ($tmp[0] eq "PRIMER_RIGHT_0") ||
     ($tmp[0] eq "PRIMER_LEFT_0_TM") ||
     ($tmp[0] eq "PRIMER_RIGHT_0_TM") ||
     ($tmp[0] eq "PRIMER_PAIR_0_PRODUCT_SIZE"))
  {
    push @output, $tmp[1];
  }
}
print $fh_out join("\t", @output)."\n";

close $fh_in;
close $fh_out;
