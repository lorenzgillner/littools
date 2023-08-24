#!/usr/bin/perl

use strict;
use warnings;
use File::Basename 'basename';
use Cwd 'abs_path';
use CAM::PDF;

sub handle_int {
  print "Interrupted ...\n";
  exit;
}

sub get_key {
	my $filename = $_[0];
	return (split /_/, $filename)[0];
}

sub get_tags {
  my $filename = $_[0];
  my @tags = split /_/, $filename;
  shift @tags;
  return join(';', @tags);
}

sub pdf2txt {
	my $filename = $_[0];
  my $pdf = CAM::PDF->new($filename) or die "Can't open file: $!";
  my $plain_text = '';
  
  for my $page_num (1 .. $pdf->numPages()) {
    my $page_text = $pdf->getPageText($page_num);
    $plain_text .= lc($page_text);
  }

  return $plain_text;
}

sub process_file {
	my $filename = $_[0];
  my $text = pdf2txt($filename);
  $text =~ tr/[a-z] / /sc;
  return $text;
}

sub write_entry {
  my $filepath = abs_path($_[0]);
  my $filename = (split /\./, basename($filepath))[0];
  my $key = get_key($filename);
  my $tags = get_tags($filename);
  print "$key,$tags,$filepath,";
  print process_file($filepath)."\n";
}

$SIG{INT} = \&handle_int;

if (@ARGV == 0 || $ARGV[0] eq '-') {
  while (<STDIN>) {
    chomp;
    write_entry($_);
  }
} else {
  foreach my $F (@ARGV) {
    write_entry($_);
  }
}
