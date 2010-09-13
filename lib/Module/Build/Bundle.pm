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
        
    my $contents = join '', <FIN>;
    close(FIN) or croak "Unable to close file: $file - $!";

    my $rv = $contents =~ s/=head1\s*CONTENTS\s*.*=head1/$pod/s;

    if (! $rv) {
        croak "No CONTENTS section replaced";
    }

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

__END__

=head1 NAME

Module::Build::Bundle - sub class aimed at supporting Tasks and Bundles

=head1 VERSION

This documentation describes version 0.01

=head1 SYNOPSIS

    #In your Build.PL
    use Module::Build::Bundle;
    
    #Example lifted from: Perl::Critic::logicLAB 
    my $build = Module::Build::Bundle->new(
        dist_author   => 'Jonas B. Nielsen (jonasbn), <jonasbn@cpan.org>',
        module_name   => 'Perl::Critic::logicLAB',
        license       => 'artistic',
        create_readme => 1,
        requires      => {
            'Perl::Critic::Policy::logicLAB::ProhibitUseLib' => '0',
            'Perl::Critic::Policy::logicLAB::RequireVersionFormat' => '0',
        },
    );
    
    $build->create_build_script();

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 ACTION_contents

=head2 ACTION_build

=head2 create_mymeta

=head2 get_metadata

=head1 DIAGNOSTICS

=over

=item * No <section> section to be replaced

=back

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item * L<Module::Build|Module::Build>

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head2 CONTENTS

The module does per default look for the section named: CONTENTS.

This is the section used in Bundles, this can be overwritten using the section
parameter.

For example L<Perl::Critic::logicLAB|Perl::Critic::logicLAB> uses a section
named POLICIES and L<Task::BeLike::JONASBN> uses DEPENDENCIES.

The problem is that the section has to be present or else the contents action
will throw an error.

=head1 AUTHOR

=over

=item * Jonas B. Nielsen (jonasbn) C<< <jonasbn@cpan.org> >>

=back

=head1 LICENSE AND COPYRIGHT