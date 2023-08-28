#!/usr/bin/perl

use strict;
use warnings;
use Tk;
use Text::CSV;

sub load_iidx {
  my $file_path = $_[0];
  my $inverse_index = $_[1];

  open(my $inverse_index_file, '<', $file_path) or die "Could not open index file: $!";

  my $csv = Text::CSV->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV->error_diag();

  while ( my $line = $csv->getline($inverse_index_file) ) {
    my $term = $line->[0];
    @{$inverse_index->{$term}} = split(/;/, $line->[1]);
  }

  close($inverse_index_file);
}

sub open_externally {
  print qq($_[0])."\n";
}

sub present_results {
  my ($listbox) = $_[0];
  shift;

  ${$listbox}->delete(0, 'end');
  foreach my $item (sort @_) {
    ${$listbox}->insert('end', $item);
  }
}

sub list_all {
  my ($inverse_index) = $_[0];
  my %document_list;

  foreach my $x (keys %{$inverse_index}) {
    foreach my $doc (@{$inverse_index->{$x}}) {
      my $document_path = (split /:/, $doc)[1];
      unless ($document_list{$document_path}) {
        $document_list{$document_path} = 1;
      }
    }
  }

  return keys %document_list;
}

sub lookup_and {
  my $query_string = $_[0];
  my @terms = (split / /, $query_string);
  #   my %matches;

  #   foreach my $term (@terms) {
        
  #   while (my $line = <$file>) {
  #     if ($line =~ /$pattern/) {
  #         print $line;
  #     }
  # }
  #   }
}

if ( @ARGV != 1 ) {
  die "Usage: $0 <iindex.csv>\n";
}

my $filename = $ARGV[0];
my $query_string = '';
my %iidx;

load_iidx($filename, \%iidx);

my $root = MainWindow->new();

$root->title("bibo");

my $entry_frame = $root->Frame(
  -height => 20
)->pack(
  -expand => 'no',
  -fill => 'x',
  -padx => 2,
  -pady => 2
);

my $query_field = $entry_frame->Entry(
  -textvariable => \$query_string,
  -font => "courier 17",
  -width => 35
)->pack(
  -expand => 'yes',
  -fill => 'x',
  -anchor => 'c',
  -side => 'left'
);

$query_field->bind('<Return>', sub {
  print "E\n";
});

my $search_button = $entry_frame->Button(
  -text => 'Go!',
  -font => "courier 13 bold",
  -padx => 2,
  -pady => 2,
  -command => sub {
    # my @results;

    # if ($query_string) { 
    #   @results = lookup_and($query_string);
    # } else {
    #   @results = list_all(\%iidx);
    # }
    
    # print_results(@results);
  }
)->pack(
  -side => 'left',
  -anchor => 'c'
);

my $result_frame = $root->Frame(
)->pack(
  -expand => 'yes',
  -fill => 'both'
);

my $scrollbar = $result_frame->Scrollbar();

my $listbox = $result_frame->Listbox(
  -selectmode => 'single',
  -font => "courier 13",
  -height => 50,
  -width => 150,
  -yscrollcommand => ['set' => $scrollbar]
);

$listbox->bind('<Double-1>', sub {
  my $selection = $listbox->get($listbox->curselection());
  open_externally($selection);
});

$scrollbar->configure(
  -command => ['yview' => $listbox]
);

$scrollbar->pack(
  -side => 'left',
  -fill => 'y'
);

$listbox->pack(
  -side => 'left',
  -expand => 'yes',
  -fill => 'both'
);

present_results(\$listbox, list_all(\%iidx));

MainLoop();