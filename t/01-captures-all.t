
use strict;
use warnings;

use Test::More tests => 400;
use FindBin;

sub jitter {
  my $i;
  for ( 0 .. int( rand(40) ) ) {
    next if 1 < rand(10);
    for ( 0 .. int( rand(10000) ) ) {
      $i++;
    }
  }
}

# NOTE: This test is hard to guarantee, its possibly random.

my $output = "w0w1w2w3w4w5w6w7w8w9w10\n" x 6 . join '', map { "<<$_>>\np0p1p2p3p4p5p6p7p8p9p10\n" } 0 .. 5;

use IPC::Run::Fused qw( run_fused );

# We do this lots to make sure theres no race conditions.
for ( 1 .. 400 ) {
  my $str = '';
  jitter;
  run_fused( my $fh, $^X, "$FindBin::Bin/tbin/01.pl" ) or die "$@";
  jitter;
  while ( my $line = <$fh> ) {
    jitter;
    $str .= $line;
  }

  is( $str, $output, 'Captures All' );
}
