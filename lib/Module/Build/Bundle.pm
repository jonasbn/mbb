package Module::Build::Bundle;

# $Id$

use 5.6.0; #$^V
use strict;
use warnings;
use Carp qw(croak);
use Cwd qw(getcwd);
use Tie::IxHash;
use English qw( -no_match_vars );
use base 'Module::Build::Base';

use constant EXTENDED_POD_LINK_VERSION => 5.12.0;

our $VERSION = '0.01';
#HACK: we need a writable copy for testing purposes
our $myPERL_VERSION = $^V; 

sub ACTION_build {
    my $self = shift;

	if (! $self->{'_completed_actions'}{'contents'}) {
		$self->ACTION_contents();
	}
	
	return Module::Build::Base::ACTION_build($self);
}

sub ACTION_contents {
    my $self = shift;
   
    #Fetching requirements from Build.PL
    my @list = %{$self->requires()};
    
    my $sorted = 'Tie::IxHash'->new(@list);
    $sorted->SortByKey();
    
    my $pod = "=head1 CONTENTS\n\n=over\n\n";
    foreach ($sorted->Keys) {
        my ($module, $version) = $sorted->Shift();
        
        my $dist = $module =~ s/::/\-/g;
        my $module_path = $module =~ s[::][/]g;
        $module_path .= '.pm';
        
        if ( $myPERL_VERSION ge EXTENDED_POD_LINK_VERSION ) {
            if ($version) {
                $pod .= "=item * L<$module|$module>, L<$version|http://search.cpan.org/dist/$dist-$version/lib/$module_path>\n\n";
            } else {
                $pod .= "=item * L<$module|$module>\n\n";
            }        
        } else {
            if ($version) {
                $pod .= "=item * L<$module|$module>, $version\n\n";
            } else {
                $pod .= "=item * L<$module|$module>\n\n";
            }
        }
    }
    $pod .= "=back\n\n=head1";

    my $cwd = getcwd();

    my @path = split /::/, $self->{properties}->{module_name}
        || $self->{properties}->{module_name};

    my $file = $cwd.'/'. (join '/', @path) .'.pm';
    open(FIN, '+<', $file)
        or croak "Unable to open file: $file - $!";
        
    my $contents = join "", <FIN>;
    $contents =~ s/=head1\s*CONTENTS\s*.*=head1/$pod/s;
    close(FIN);

    open(FOUT, '>', $file)
        or croak "Unable to open file: $file - $!";
    print FOUT $contents;
    close(FOUT) or croak "Unable to close file: $file - $!";

	return 1;
}

#lifted from Module::Build::Base
sub create_mymeta {
  my ($self) = @_;
  my $mymetafile = $self->mymetafile;
  my $metafile = $self->metafile;

  # cleanup
  if ( $self->delete_filetree($mymetafile) ) {
    $self->log_verbose("Removed previous '$mymetafile'\n");
  }
  $self->log_info("Creating new '$mymetafile' with configuration results\n");

  # use old meta and update prereqs, if possible
  my $mymeta;
  if ( -f $metafile ) {
    $mymeta = eval { $self->read_metafile( $self->metafile ) };
  }
  # if we read META OK, just update it
  if ( defined $mymeta ) {
    my $prereqs = $self->_normalize_prereqs;
    for my $t ( keys %$prereqs ) {
        $mymeta->{$t} = $prereqs->{$t};
    }
  }
  # but generate from scratch, ignoring errors if META doesn't exist
  else {
    $mymeta = $self->get_metadata( fatal => 0 );
  }

  my $package = ref $self;
  
  # MYMETA is always static
  $mymeta->{dynamic_config} = 0;
  # Note which M::B created it
  #JONASBN: changed from originally lifted code
  $mymeta->{generated_by}
    = "$package version $VERSION";

  $self->write_metafile( $mymetafile, $mymeta );
  return 1;
}

#lifted from Module::Build::Base
sub get_metadata {
  my ($self, %args) = @_;

  my $metadata = {};
  $self->prepare_metadata( $metadata, undef, \%args );

  my $package = ref $self;

  #JONASBN: changed from originally lifted code  
  $metadata->{generated_by}
    = "$package version $VERSION";

  #JONASBN: changed from originally lifted code
  $metadata->{configure_requires} 
    = { "$package" => $VERSION };
  
  return $metadata;
}

1;

