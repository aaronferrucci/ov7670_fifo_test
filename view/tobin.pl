use strict;
use warnings;

my @bytes = ();
my $bytecount = 0;
while (<>) {
  if (/^:01.{4}.{2}(.{2}).{2}$/) {
    my $byte = $1;
    push @bytes, pack('H*', $byte);
    ++$bytecount;
    last if ($bytecount == 640*102);
  }
}

open my $fh, '>:raw', "pix.bin" or die;
print $fh join('', @bytes);
close $fh;
