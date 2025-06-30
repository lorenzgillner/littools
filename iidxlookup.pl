#!/usr/bin/perl

use strict;
use warnings;

use Tk;
use Tk::Photo;
use Tk::ProgressBar;
use Tk::StatusBar;

use Text::CSV;
use Getopt::Long;

# allow umlaut characters in output
binmode STDOUT, ':utf8';

my $app_title = $0;
my $app_font  = 'sans 13';

# if ( @ARGV != 1 ) {
#   die 'Usage: $0 <my_inverse_index.csv>\n';
# }

GetOptions(
    'title|t=s' => \$app_title,
    'font|f=s'  => \$app_font
) or die('Error in command line arguments\n');

my $filename     = $ARGV[0];
my $query_string = '';
my %iidx;

# +-----------------+
# | interface setup |
# +-----------------+

my $mw = MainWindow->new();

$mw->title($app_title);
$mw->idletasks;
#$mw->#TODO center me

my $font = $app_font;

my $result_frame = $mw->Frame()->pack(
    -expand => 1,
    -fill   => 'both',
    -side   => 'bottom'
);

my $scrollbar = $result_frame->Scrollbar();

my $result_list = $result_frame->Listbox(
    -selectmode        => 'single',
    -font              => $font,
    -width             => 100,
    -height            => 25,
    -background        => 'white',
    -foreground        => 'black',
    -selectmode        => 'single',
    -selectbackground  => '#80cbf5',
    -selectforeground  => 'black',
    -selectborderwidth => 0,
    -yscrollcommand    => [ 'set' => $scrollbar ],
);

$scrollbar->configure( -command => [ 'yview' => $result_list ] );

$scrollbar->pack(
    -side => 'right',
    -fill => 'y'
);

$result_list->pack(
    -side   => 'right',
    -expand => 1,
    -fill   => 'both'
);

my $entry_frame = $mw->Frame( -height => 20 )->pack(
    -expand => 0,
    -fill   => 'both',
    -padx   => 2,
    -pady   => 2,
    -side   => 'top'
);

$entry_frame->gridRowconfigure( 0, -weight => 1 );

my $open_button = $entry_frame->Button(
    -text    => 'Reload',
    -font    => $font,
    -padx    => 2,
    -pady    => 2,
    -command => sub {
	load_iidx( $filename, \%iidx );
	present_results( \$result_list, list_all( \%iidx ) );
    }
)->pack(
    -side   => 'left',
    -anchor => 'c'
);

my $query_field = $entry_frame->Entry(
    -textvariable => \$query_string,
    -font         => $font,
    -background   => 'white',
    -foreground   => 'black'
)->pack(
    -expand => 1,
    -fill   => 'x',
    -anchor => 'c',
    -side   => 'left'
);

my $search_button = $entry_frame->Button(
    -text    => 'Search',
    -font    => $font,
    -padx    => 2,
    -pady    => 2,
    -command => sub {
        search_and_present( $query_string, \%iidx, \$result_list );
    }
)->pack(
    -side   => 'left',
    -anchor => 'c'
    );

my $status_bar = $mw->StatusBar();
my $counter = 0;
my $status = "Ready";
$status_bar->addLabel(-textvariable => \$counter, -width => 10);
$status_bar->addLabel(-textvariable => \$status);

# +--------------+
# | key bindings |
# +--------------+

$result_list->bind(
    '<Double-1>',
    sub {
        my $selection = $result_list->get( $result_list->curselection() );
        open_externally($selection);
    }
);

$query_field->bind(
    '<Return>',
    sub {
        search_and_present( $query_string, \%iidx, \$result_list );
    }
);

$mw->bind( '<Control-q>', sub { exit } );

$mw->bind(
    '<Control-r>',
    sub {
        load_iidx( $filename, \%iidx );
        present_results( \$result_list, list_all( \%iidx ) );
    }
);

# +-----------+
# | main loop |
# +-----------+

# schedule document loading
$mw->after(
    10,
    sub {
        load_iidx( $filename, \%iidx );
        present_results( \$result_list, list_all( \%iidx ) );
        $query_field->focus;
    }
);

# start the main loop
MainLoop();

# +---------------+
# | GUI functions |
# +---------------+

sub show_about_dialog {
    my $about_dialog = $mw->Toplevel;
    $about_dialog->transient($mw);
    $about_dialog->title('About');
    $about_dialog->geometry('200x100');
    $about_dialog->resizable( 0, 0 );

    $about_dialog->protocol( 'WM_DELETE_WINDOW',
        sub { $about_dialog->destroy } );
    my $sample_text = $about_dialog->Label( -text => $app_title )
      ->pack( -pady => [ 10, 5 ], -padx => 10 );
    my $close_button = $about_dialog->Button(
        -text    => 'Close',
        -command => sub { $about_dialog->destroy }
    )->pack( -pady => [ 5, 10 ], -padx => 10, -side => 'bottom' );
}

# +-------------------+
# | utility functions |
# +-------------------+

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
    my $file_path     = $_[0];
    my $inverse_index = $_[1];

    my $line_count = `wc -l < $file_path`;
    chomp($line_count);

    my $lines_read  = 0;
    my $num_blocks  = 20;
    my $blocks_done = 0;
    my $last_block  = 0;

    my $loading_dialog = $mw->Toplevel;
    $loading_dialog->transient($mw);
    $loading_dialog->resizable( 0, 0 );

    #$loading_dialog->overrideredirect(1);
    $loading_dialog->title('Loading ...');

    my $loading_text =
      $loading_dialog->Label( -text => 'Reading index file: ' . $file_path, )
      ->pack(
        -pady => [ 10, 0 ],
        -padx => 10
      );

    my $progress = $loading_dialog->ProgressBar(
        -width    => 20,
        -length   => 300,
        -from     => 0,
        -to       => $num_blocks,
        -blocks   => $num_blocks,
        -gap      => 1,
        -colors   => [ 0, 'dark green' ],
        -variable => \$blocks_done,
        -relief   => 'sunken',
    )->pack(
        -pady => 10,
        -padx => 10
    );

    $loading_dialog->Popup(
        -popover    => $mw,
        -overanchor => 'c',
        -popanchor  => 'c',
    );

    open( my $inverse_index_file, '<', $file_path )
      or die 'Could not open index file: $!';

    my $csv = Text::CSV->new( { binary => 1 } )
      or die 'Cannot use CSV: ' . Text::CSV->error_diag();

    while ( my $line = $csv->getline($inverse_index_file) ) {
        my $term = $line->[0];
        @{ $inverse_index->{$term} } =
          deduplicate( split( /;/, $line->[1] ) );   # ... in case of soft links
        $lines_read++;
        $blocks_done = int( ( $lines_read / $line_count ) * $num_blocks );

        if ( $last_block != $blocks_done ) {
            $loading_dialog->update('idletasks');
        }
        $last_block = $progress->value;
    }

    close($inverse_index_file);

    $loading_dialog->destroy;
}

sub open_externally {
    print qq($_[0]\n);
}

sub get_path_only {
    return ( split /:/, $_[0] )[1];
}

sub present_results {
    my ($listbox) = $_[0];
    shift;

    ${$listbox}->delete( 0, 'end' );
    foreach my $item ( sort @_ ) {
        ${$listbox}->insert( 'end', $item );
    }

    $counter = scalar(@_);
    $status = "Ready";
}

sub list_all {
    my ($inverse_index) = $_[0];
    my %document_list;

    foreach my $term ( keys %{$inverse_index} ) {
        foreach my $doc ( @{ $inverse_index->{$term} } ) {
            my $document_path = get_path_only($doc);
            unless ( $document_list{$document_path} ) {
                $document_list{$document_path} = 1;
            }
        }
    }

    return keys %document_list;
}

sub search {
    my $query_string = $_[0];
    my ($inverse_index) = $_[1];

    my @terms = ( split /\s+/, $query_string );

    my %hits;

    $status = "Searching ...";

    foreach my $doc ( @{ $inverse_index->{ $terms[0] } } ) {
        my $document_path = get_path_only($doc);
        unless ( exists $hits{$document_path} ) {
            $hits{$document_path} = 1;
        }
    }

    # only bother continuing if the first term was matched
    if ( scalar keys %hits ) {
        for my $i ( 1 .. $#terms ) {
            foreach my $doc ( @{ $inverse_index->{ $terms[$i] } } ) {
                my $document_path = get_path_only($doc);
                if ( exists $hits{$document_path} ) {
                    $hits{$document_path}++;
                }
            }
        }
    }

    my @document_list;

    foreach my $key ( keys %hits ) {
        if ( $hits{$key} >= scalar @terms ) {
            push @document_list, $key;
        }
    }

    return @document_list;
}

sub search_and_present {
    my $query_string    = lc( $_[0] );
    my ($inverse_index) = $_[1];
    my ($listbox)       = $_[2];

    my @results;

    if ($query_string) {
        @results = search( $query_string, $inverse_index );
    }
    else {
        @results = list_all($inverse_index);
    }

    if ( scalar @results ) {
        present_results( $listbox, @results );
    }
    else {
        ${$listbox}->delete( 0, 'end' );
    }
}
