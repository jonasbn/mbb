package Module::Build::Bundle;

# $Id$

use 5.006;    #$^V
use strict;
use warnings;
use Carp qw(croak);
use Cwd qw(getcwd);
use Tie::IxHash;
use English qw( -no_match_vars );
use File::Slurp; #read_file
use base qw(Module::Build);

use constant EXTENDED_POD_LINK_VERSION => 5.12.0;

our $VERSION = '0.11';

#HACK: we need a writable copy for testing purposes
## no critic qw(Variables::ProhibitPackageVars Variables::ProhibitPunctuationVars)
our $myPERL_VERSION = $^V;

sub ACTION_build {
    my $self = shift;

    if ( !$self->{'_completed_actions'}{'contents'} ) {
        $self->ACTION_contents();
    }

    return Module::Build::Base::ACTION_build($self);
}

sub ACTION_contents {
    my $self = shift;

    #Fetching requirements from Build.PL
    my @list = %{ $self->requires() };

    my $section_header = $self->notes('section_header') || 'CONTENTS';

    my $sorted = 'Tie::IxHash'->new(@list);
    $sorted->SortByKey();

    my $pod = "=head1 $section_header\n\n=over\n\n";
    foreach ( $sorted->Keys ) {
        my ( $module, $version ) = $sorted->Shift();

        my $dist = $module;
        $dist =~ s/::/\-/g;

        my $module_path = $module;
        $module_path =~ s[::][/]g;
        $module_path .= '.pm';

        if ( $myPERL_VERSION ge EXTENDED_POD_LINK_VERSION ) {
            if ($version) {
                $pod .= "=item * L<$module|$module>, "
                    . "L<$version|http://search.cpan.org/dist/$dist-$version/lib/$module_path>\n\n";
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

    #HACK: induced from test suite
    my $dir = $self->notes('temp_wd') ? $self->notes('temp_wd') : 'blib/lib';

   ## no critic qw(ValuesAndExpressions::ProhibitNoisyQuotes)
    my $file = ( join '/', ( $cwd, $dir, @path ) ) . '.pm';

    my $contents = read_file( $file );
    
    my $rv = $contents =~ s/=head1\s*$section_header\s*.*=head1/$pod/s;

    if ( !$rv ) {
        croak "No $section_header section replaced";
    }

    my $permissions = (stat $file)[2] & 07777;
    chmod 0644, $file or croak "Unable to make file: $file writable - $!";
    
    open my $fout, '>', $file
        or croak "Unable to open file: $file - $!";
        
    print $fout $contents;
    
    chmod $permissions, $file
        or croak "Unable to reinstate permissions for file: $file - $!";
    
    close $fout or croak "Unable to close file: $file - $!";

    return 1;
}

#lifted from Module::Build::Base
sub create_mymeta {
    my ($self)     = @_;
    my $mymetafile = $self->mymetafile;
    my $metafile   = $self->metafile;

    # cleanup
    if ( $self->delete_filetree($mymetafile) ) {
        $self->log_verbose("Removed previous '$mymetafile'\n");
    }
    $self->log_info(
        "Creating new '$mymetafile' with configuration results\n");

    # use old meta and update prereqs, if possible
    my $mymeta;
    if ( -e $metafile ) {
        $mymeta = eval { $self->read_metafile( $self->metafile ) };
    }

    # if we read META OK, just update it
    if ( defined $mymeta ) {
        my $prereqs = $self->_normalize_prereqs;
        for my $t ( keys %{$prereqs} ) {
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
    $mymeta->{generated_by} = "$package version $VERSION";

    $self->write_metafile( $mymetafile, $mymeta );
    return 1;
}

#lifted from Module::Build::Base
sub get_metadata {
    my ( $self, %args ) = @_;

    my $metadata = {};
    $self->prepare_metadata( $metadata, undef, \%args );

    my $package = ref $self;

    #JONASBN: changed from originally lifted code
    $metadata->{generated_by} = "$package version $VERSION";

    #JONASBN: changed from originally lifted code
    $metadata->{configure_requires} = { "$package" => $VERSION };

    return $metadata;
}

#Lifed from Module::Build::Base
sub do_create_metafile {
    my $self = shift;
    return if $self->{wrote_metadata};

    my $p        = $self->{properties};
    #JONASBN: changed from originally lifted code
    my $metafile = $self->metafile;

    unless ( $p->{license} ) {
        $self->log_warn(
            "No license specified, setting license = 'unknown'\n");
        $p->{license} = 'unknown';
    }
    unless ( exists $self->valid_licenses->{ $p->{license} } ) {
        croak "Unknown license type '$p->{license}'";
    }

    # If we're in the distdir, the metafile may exist and be non-writable.
    $self->delete_filetree($metafile);
    $self->log_info("Creating $metafile\n");

    # Since we're building ourself, we have to do some special stuff
    # here: the ConfigData module is found in blib/lib.
    local @INC = @INC;
    if ( ( $self->module_name || '' ) eq 'Module::Build' ) {
        $self->depends_on('config_data');
        push @INC, File::Spec->catdir( $self->blib, 'lib' );
    }

    if ($self->write_metafile(
            $self->metafile, $self->get_metadata( fatal => 1 )
        )
        )
    {
        $self->{wrote_metadata} = 1;
        $self->_add_to_manifest( 'MANIFEST', $metafile );
    }

    return 1;
}

1;

__END__

=head1 NAME

Module::Build::Bundle - subclass for supporting Tasks and Bundles

=head1 VERSION

This documentation describes version 0.09

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


    #In your shell
    % ./Build contents
    
    #Or implicitly executing contents action
    % ./Build
    
=head1 DESCRIPTION

=head2 FEATURES

=over

=item * Autogeneration of POD for Bundle and Task distributions via a build action

=item * Links to required/listed distributions, with or without versions

=item * Links to specific versions of distributions for perl 5.12.0 or newer if a 
version is specified

=item * Inserts a POD section named CONTENTS or something specified by the
caller

=back

This module adds a very basic action for propagating a requirements list from
a F<Build.PL> file's requires section to the a POD section in a designated
distribution.

=head1 SUBROUTINES/METHODS

=head2 ACTION_contents

This is the build action parsing the requirements specified in the F<Build.PL>
file. It creates a POD section (see also L</FEATURES> above).

By default it overwrites the CONTENTS section with a POD link listing. You can
specify a note indicating if what section you want to overwrite using the
section_header note.

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
    
    $build->notes('section_header' => 'POLICIES');

    $build->create_build_script();

The section of course has to be present.

Based on your version of perl and your F<Build.PL> requirements, the links will
be rendered in the following formats:

Basic:

    #Build.PL
    requires => {
        'Some::Package' => '0',
    }

    #POD, perl all
    =item * L<Some::Package|Some::Package>

With version:

    #Build.PL
    requires => {
        'Some::Package' => '1.99',
    }

    #POD, perl < 5.12.0
    =item * L<Some::Package|Some::Package>, 1.99

    #POD, perl >= 5.12.0
    =item * L<Some::Package|Some::Package>, L<1\.99\|http://search.cpan.org/dist/Some-Package-1.99/lib/Some/Package.pm>

=head2 ACTION_build

This is a simple wrapper around the standard action: L<Module::Build|Module::Build>
build action. It checks whether L</ACTION_contents> have been executed, if not
it executes it.

=head2 create_mymeta

This method has been lifted from L<Module::Build::Base|Module::Build::Base> and altered.

It sets the:

=over

=item * 'generated by <package> version <package version>' string in F<MYMETA.yml>

=back

For Module::Build::Bundle:

    #Example MYMETA.yml
    configure_requires:
        Module::Build::Bundle: 0.01
    generated_by: 'Module::Build::Bundle version 0.01'
    
=head2 get_metadata

This method has been lifted from L<Module::Build::Base|Module::Build::Base> and
altered.

It sets:

=over

=item * 'generated by <package> version <package version>' string in F<META.yml>

=item * configure_requires: <package>: <version> 

=back

For Module::Build::Bundle:

    #Example META.yml
    configure_requires:
        Module::Build::Bundle: 0.01
    generated_by: 'Module::Build::Bundle version 0.01'

=head2 do_create_metafile

This method has been lifted from L<Module::Build::Base|Module::Build::Base> and
altered.

The method was overwritten to be more testable. The method created the relevant
META file.

=head1 DIAGNOSTICS

=over

=item * No <section> section to be replaced

If the POD to be updated does not contain a placeholder section the action
will die with the above message.

The default minimal section should look something like:

    =head1 CONTENTS
    
    =head1
    
Or if you provide your own section_header

    =head1 <section header>
    
    =head1

=back

=head1 CONFIGURATION AND ENVIRONMENT

=head2 CONTENTS SECTION

The module does per default look for the section named: CONTENTS.

This is the section used in Bundles, this can be overwritten using the section
parameter.

For example L<Perl::Critic::logicLAB|Perl::Critic::logicLAB> uses a section
named POLICIES and L<Task::BeLike::JONASBN> uses DEPENDENCIES.

The problem is that the section has to be present or else the contents action
will throw an error.

Module::Build::Bundle is primarily aimed at Bundle distributions. Their use is
however no longer recommended and L<Task> provides a better way.

=head1 DEPENDENCIES

=over

=item * perl 5.6.0

=item * L<Module::Build::Base|Module::Build::Base>, part of the L<Module::Build>
distribution

=back

=head1 INCOMPATIBILITIES

The distribution requires perl version from 5.6.0 and up.

=head1 BUGS AND LIMITATIONS

Currently Module::Build::Bundle is not able to handle root based distributions
meaning distributions with a single Perl module located in the root directory
instead of the lib structure.

Apart from that there are no known special limitations or bugs at this time,
but I am certain there are plenty of scenarios is distribution packaging the
module is not currently handling.

The module only supports Bundle/Task distributions based on L<Module::Build>.
The implementation is based on a subclass of L<Module::Build>, which can replace
L<Module::Build> in your F<Build.PL> (See: L</SYNOPSIS>).

As described previously in the documentation a section of documentation can only
replaced. A section with the generated contents cannot be added with out a
placeholder in the form of designated section title. This might be changed in the
future.

=head1 BUG REPORTING

=head1 TEST AND QUALITY

=head2 TEST COVERAGE

----------------------------------- ------ ------ ------ ------ ------ ------
File                                  stmt   bran   cond    sub   time  total
----------------------------------- ------ ------ ------ ------ ------ ------
lib/Module/Build/Bundle.pm            73.7   50.0   57.1   85.7  100.0   69.0
Total                                 73.7   50.0   57.1   85.7  100.0   69.0
----------------------------------- ------ ------ ------ ------ ------ ------

The above coverage report is based on release 0.08

=head1 QUALITY AND CODING STANDARD

=head1 DEVELOPMENT

=head1 TODO

Please see: L<https://logiclab.jira.com/browse/MBB#selectedTab=com.atlassian.jira.plugin.system.project%3Aroadmap-panel>

=head1 SEE ALSO

=over

=item * L<Task|Task>

=item * L<TaskBeLike::JONASBN|TaskBeLike::JONASBN>

=item * L<Perl::Critic::logicLAB|Perl::Critic::logicLAB>

=item * L<CPAN|CPAN>

=item * L<CPAN::Bundle|http://cpansearch.perl.org/src/ANDK/CPAN-1.9402/lib/CPAN/Bundle.pm>

=item * L<https://logiclab.jira.com/wiki/display/OPEN/Module-Build-Bundle>

=back

=head1 MOTIVATION

The motivation was driven by two things.

=over

=item * The joy of fooling around with L<Module::Build|Module::Build>

=item * The need for automating the documentation generation

=back

I have a few perks and one of them is that I never get to automate stuff until
very late and I always regret that. So when I released
L<Bundle::JONASBN|Bundle::JONASBN>, now L<Task::BeLike::JONASBN::Task::BeLike::JONASBN>
I thought I might aswell get it automated right away.

This module lived for a long time as a part of L<Bundle::JONASBN|Bundle::JONASBN>
but then I needed it for some other distributions, so I decided to separate it out.

=head1 ACKNOWLEDGEMENTS

=over

=item * Adam Kennedy (ADAMK) author of L<Task>, a very basic and simple solution

=item * The L<Module::Build> developers

=item * Lars Dɪᴇᴄᴋᴏᴡ (DAXIM) for reporting RT:83754, resulting in release 0.11

=back

=head1 AUTHOR

=over

=item * Jonas B. Nielsen (jonasbn) C<< <jonasbn@cpan.org> >>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2013 jonasbn, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
