package Test::Class::Module::Build::Bundle;

# $Id$

use strict;
use warnings;
use Test::More;
use Module::Build::YAML;
use Test::MockObject::Extends;
use FindBin;
use lib "$FindBin::Bin/../t";

use base qw(Test::Class);

sub startup : Test(startup) {
    my $test = shift;
    
    my $yaml = Module::Build::YAML->new();
    
    $test->{yaml} = $yaml;
}

sub setup : Test(setup => 2) {
    my $test = shift;
    
    use_ok('Module::Build::Bundle');
    
    ok(my $build = Module::Build::Bundle->new(
        module_name  => 'Dummy',
        dist_version => '6.66',
        dist_author  => 'jonasbn',
        dist_abstract => 'this is a dummy',
    ), 'calling constructor');

	$build = Test::MockObject::Extends->new( $build );
	
	$build->set_true('_add_to_manifest');

    $test->{version} = $Module::Build::Bundle::VERSION;
    $test->{package} = ref $build;
    $test->{build} = $build;
    $test->{canonical} = $test->{version};
};

sub do_create_meta : Test(8) {
    my $test = shift;

    my $build = $test->{build};
    my $yaml = $test->{yaml};
    my $package = $test->{package};
    my $version = $test->{version};
    my $canonical_version = $test->{canonical};
    
    ok($build->metafile('t/testMETA.yml'), 'setting META file name to testMETA.yml');
    ok($build->metafile2('t/testMETA.json'), 'setting META file name to testMETA.json');

    ok($build->do_create_metafile, 'creating META file');
    
    my $filename = $build->metafile;
    my $meta = $yaml->read($filename)->[0];
    
    if ($yaml->errstr) {
        croak $yaml->errstr;
    }

    like($meta->{generated_by}, qr/\A$package version \d+\.\d+(?:,\s+\w+)*/, q[asserting 'generated_by']);
    
    like($meta->{generated_by}, qr/\A$package version $version(?:,\s+\w+)*/, q[asserting 'generated_by']);

    ok(my $req = $meta->{configure_requires}, q[checking 'configure_requires']);
    
    like($req->{$package}, qr/\A\d+\.\d+\z/, 'asserting version number format');
    
    is($req->{$package}, $canonical_version, 'asserting version against canonical version');

    $test->{file} = $build->metafile;
};

1;
