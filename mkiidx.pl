#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;

sub deduplicate {
    my @array_with_duplicates = @_;

    my @array_without_duplicates;
    my %seen;

    foreach my $element (@array_with_duplicates) {
        unless ( $seen{$element} ) {
            push @array_without_duplicates, $element;
            $seen{$element} = 1;
        }
    }

    return @array_without_duplicates;
}

if ( @ARGV != 1 ) {
    die "Usage: $0 <database.csv>\n";
}

my $db = $ARGV[0];

my %iidx;

my $csv = Text::CSV->new( { binary => 1 } )
  or die "Cannot use CSV: " . Text::CSV->error_diag();

open( my $f, '<', $db ) or die "Could not open '$db': $!";

while ( my $line = $csv->getline($f) ) {
    my $key   = $line->[0];
    my @tags  = split( /;/, $line->[1] );
    my $path  = $line->[2];
    my @words = split( ' ', $line->[3] );

    # this is stupid, but sufficient for now
    push @words, @tags;

    @words = deduplicate(@words);

    while ( my $word = shift @words ) {
        if ( !$iidx{$word} ) {
            @{ $iidx{$word} } = ($key.":".$path);
        }
        else {
            push @{ $iidx{$word} }, $key.":".$path;
        }
    }
}

if ( $csv->eof ) {
    close($f);
}
else {
    $csv->error_diag();
}

foreach my $k ( keys %iidx ) {
    print "$k,";
    print join( ';', @{ $iidx{$k} } ) . "\n";
}
