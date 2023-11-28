#!/usr/bin/perl

use strict;
use warnings;
use Tk;
use Text::CSV;

# allow umlaut characters in output
binmode STDOUT, ":utf8";

if ( @ARGV != 1 ) {
  die "Usage: $0 <inverseindex.csv>\n";
}

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

sub load_iidx {
  my $file_path = $_[0];
  my $inverse_index = $_[1];

  open(my $inverse_index_file, '<', $file_path) or die "Could not open index file: $!";

  my $csv = Text::CSV->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV->error_diag();

  while ( my $line = $csv->getline($inverse_index_file) ) {
    my $term = $line->[0];
    @{$inverse_index->{$term}} = deduplicate(split(/;/, $line->[1])); # ... in case of soft links
  }

  close($inverse_index_file);
}

sub open_externally {
  print qq($_[0])."\n";
}

sub get_path_only {
  return (split /:/, $_[0])[1];
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

  foreach my $term (keys %{$inverse_index}) {
    foreach my $doc (@{$inverse_index->{$term}}) {
      my $document_path = get_path_only($doc);
      unless ($document_list{$document_path}) {
        $document_list{$document_path} = 1;
      }
    }
  }

  return keys %document_list;
}

sub search {
  my $query_string = $_[0];
  my ($inverse_index) = $_[1];
  
  my @terms = (split /\s+/, $query_string);

  my %hits;

  foreach my $doc (@{$inverse_index->{$terms[0]}}) {
    my $document_path = get_path_only($doc);
    unless (exists $hits{$document_path}) {
      $hits{$document_path} = 1;
    }
  }

  # only bother continuing if the first term was matched 
  if (scalar keys %hits) {
    for my $i (1 .. $#terms) {
      foreach my $doc (@{$inverse_index->{$terms[$i]}}) {
        my $document_path = get_path_only($doc);
        if (exists $hits{$document_path}) {
          $hits{$document_path}++;
        }
      }
    }
  }

  my @document_list;
  
  foreach my $key (keys %hits) {
    if ($hits{$key} >= scalar @terms) {
      push @document_list, $key;
    }
  }
  
  return @document_list;
}

sub search_and_present {
  my $query_string = lc($_[0]);
  my ($inverse_index) = $_[1];
  my ($listbox) = $_[2];

  my @results;

  if ($query_string) {
    @results = search($query_string, $inverse_index);
  } else {
    @results = list_all($inverse_index);
  }
  
  if (scalar @results) {
    present_results($listbox, @results);
  } else {
    ${$listbox}->delete(0, 'end');
  }
}

my $filename = $ARGV[0];
my $query_string = '';
my %iidx;

load_iidx($filename, \%iidx);

# +-----------------+
# | interface setup |
# +-----------------+

my $root = MainWindow->new();

$root->title("$0: $filename");

my $font = 'courier 12';

my $result_frame = $root->Frame(
)->pack(
  -expand => 1,
  -fill => 'both',
  -side => 'bottom',
);

my $scrollbar = $result_frame->Scrollbar();

my $result_list = $result_frame->Listbox(
  -selectmode => 'single',
  -font => $font,
  -width => 100,
  -height => 33,
  -yscrollcommand => ['set' => $scrollbar]
);

$scrollbar->configure(
  -command => ['yview' => $result_list]
);

$scrollbar->pack(
  -side => 'left',
  -fill => 'y'
);

$result_list->pack(
  -side => 'right',
  -expand => 1,
  -fill => 'both'
);

my $entry_frame = $root->Frame(
  -height => 20
)->pack(
  -expand => 0,
  -fill => 'x',
  -padx => 2,
  -pady => 2,
  -side => 'top'
);

$entry_frame->gridRowconfigure(0, -weight => 1);

my $reload_button = $entry_frame->Button(
  -text => "Reload",
  -font => $font,
  -padx => 2,
  -pady => 2,
  -command => sub {
    load_iidx($filename, \%iidx);
    present_results(\$result_list, list_all(\%iidx));
  }
)->pack(
  -side => 'left',
  -anchor => 'c'
);

my $query_field = $entry_frame->Entry(
  -textvariable => \$query_string,
  -font => $font
)->pack(
  -expand => 1,
  -fill => 'x',
  -anchor => 'c',
  -side => 'left'
);

my $search_button = $entry_frame->Button(
  -text => "Search",
  -font => $font,
  -padx => 2,
  -pady => 2,
  -command => sub {
    search_and_present($query_string, \%iidx, \$result_list);
  }
)->pack(
  -side => 'left',
  -anchor => 'c'
);

# +--------------+
# | key bindings |
# +--------------+

$result_list->bind('<Double-1>', sub {
  my $selection = $result_list->get($result_list->curselection());
  open_externally($selection);
});

$query_field->bind('<Return>', sub {
  search_and_present($query_string, \%iidx, \$result_list);
});

$root->bind('<Control-q>', sub { exit });

# +-----------+
# | main loop |
# +-----------+

present_results(\$result_list, list_all(\%iidx));

$query_field->focus;

MainLoop();
