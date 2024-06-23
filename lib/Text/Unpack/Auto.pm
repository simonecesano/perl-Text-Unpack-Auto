use strict;
use warnings;
package Text::Unpack::Auto;

# ABSTRACT: automatically generates unpack strings

use parent 'Exporter';  # inherit all of Exporter's methods
use List::Util qw(reduce pairs pairmap max min sum);

our @EXPORT = qw(guess_unpack auto_unpack);
our @EXPORT_OK = qw(rle_encode rle_decode rl_to_unpack);  # symbols to export on reques

sub rle_encode { shift =~ s/(.)\1*/$1 . ":" . length($&) . " "/grse }

sub rle_decode { shift =~ s/(\d+):(.) /$2 x $1/grse }

sub rl_to_unpack { join '', pairmap { ($a ? 'a' : 'x') . $b } (map { split ":", $_  } split ' ', shift()) }

sub guess_unpack {
    my @lines = @_;
    my @zeros = @lines;

    @zeros = map { s/\S/1/g, s/\s/0/g; $_ } @zeros;

    my $result = reduce { $a | $b } @zeros;

    my $unpack = rl_to_unpack(rle_encode($result));
    return $unpack;
}

sub auto_unpack {
    my @lines = @_;
    my $unpack = guess_unpack(@lines);
    my $ml = max map { length($_) } @lines;

    return map { [ map { s/^\s+|\s+$//gr } unpack $unpack, sprintf '%-' . $ml . 's',   $_ ] } @lines

}

1;
