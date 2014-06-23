package Test::Class::Module::Build::Bundle;

# $Id$

use strict;
use warnings;
use Test::More;
use CPAN::Meta::YAML;
use Test::MockObject::Extends;
use FindBin;
use lib "$FindBin::Bin/../t";
use File::Tempdir;

use base qw(Test::Class);

sub startup : Test(startup) {
    my $test = shift;

    my $yaml   = CPAN::Meta::YAML->new();
    my $tmpdir = File::Tempdir->new(CLEANUP => 0);

    $test->{yaml}   = $yaml;
    $test->{tmpdir} = $tmpdir;
}

sub setup : Test(setup => 3) {
    my $test = shift;

    ok(-e $test->{tmpdir}->name, 'temporary directory created');

    diag($test->{tmpdir}->name);

    use_ok('Module::Build::Bundle');

    ok( my $build = Module::Build::Bundle->new(
            module_name        => 'Dummy',
            dist_version       => '6.66',
            dist_author        => 'jonasbn',
            dist_abstract      => 'this is a dummy',
            configure_requires => { 'Module::Build' => '0.42' }
        ),
        'calling constructor'
    );

    $build = Test::MockObject::Extends->new($build);

    $build->set_true('_add_to_manifest');

    $test->{version}   = $Module::Build::Bundle::VERSION;
    $test->{package}   = ref $build;
    $test->{build}     = $build;
    $test->{canonical} = $test->{version};
}

sub do_create_metafile : Test(12) {
    my $test = shift;

    my $build             = $test->{build};
    my $yaml              = $test->{yaml};
    my $package           = $test->{package};
    my $version           = $test->{version};
    my $canonical_version = $test->{canonical};

    ok( $build->metafile( $test->{tmpdir}->name . '/testMETA.yml' ),
        'setting META file name to testMETA.yml' );
    ok( $build->metafile2( $test->{tmpdir}->name . '/testMETA.json' ),
        'setting META file name to testMETA.json' );

    ok( $build->do_create_metafile, 'creating META files' );

    ok( -e $build->metafile,  'metafile ' . $build->metafile . ' exists' );
    ok( -e $build->metafile2, 'metafile2 ' . $build->metafile2 . ' exists' );

    ok( -r $build->metafile,  'metafile ' . $build->metafile . ' is readable' );
    ok( -r $build->metafile2, 'metafile2 ' . $build->metafile2 . ' is readable' );

    my $filename = $build->metafile;

    diag( "my file: ",  $build->metafile );
    diag( "my file2: ", $build->metafile2 );

    #my $meta = $yaml->read($filename)->[0];

    #my $meta = $build->read_metafile( $build->metafile );
    my $meta = CPAN::Meta->load_file($build->metafile);

    if ( $yaml->errstr ) {
        croak $yaml->errstr;
    }

    like(
        $meta->{generated_by},
        qr/\A$package version \d+\.\d+(?:,\s+\w+)*/,
        q[asserting 'generated_by']
    );

    like(
        $meta->{generated_by},
        qr/\A$package version $version(?:,\s+\w+)*/,
        q[asserting 'generated_by']
    );

    ok( my $req = $meta->{configure_requires},
        q[checking 'configure_requires']
    );

    like( $req->{$package}, qr/\A\d+\.\d+\z/,
        'asserting version number format' );

    is( $req->{$package}, $canonical_version,
        'asserting version against canonical version' );

    $test->{file} = $build->metafile;
}

1;
