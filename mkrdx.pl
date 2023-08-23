#!/bin/perl

use strict;
use warnings;
use Text::CSV;

my $db = @ARGV[1];

my @corpus = ();

my $csv = Text::CSV->new({ binary => 1 }) or die "Cannot use CSV: " . Text::CSV->error_diag();

open(my $f, '<', $db) or die "Could not open '$db': $!";

while (my $line = $csv->getline($f)) {
	my $key = $line->[0];
	my @tags = split(/#/, $line->[1]);
	my $path = $line->[2];
	my @words = split(/ /, chomp($line->[3]));
}

if ($csv->eof) {
    close($f);
} else {
    $csv->error_diag();
}
