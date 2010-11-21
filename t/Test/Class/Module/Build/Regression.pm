package Test::Class::Module::Build::Regression;

# $Id$

use strict;
use warnings;
use Test::More;
use Test::MockObject::Extends;
use Module::Build::YAML;
use Module::Build;

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
    
    use_ok('Module::Build');

    ok(my $build = Module::Build->new(
        module_name  => 'Dummy',
        dist_version => '6.66',
        dist_author  => 'jonasbn',
        dist_abstract => 'this is a dummy',
    ), 'calling constructor');

	my $package_name = ref $build;

	$build = Test::MockObject::Extends->new( $build );
	$build->set_true('_add_to_manifest');

    $test->{version} = $Module::Build::VERSION;
    $test->{package} = $package_name; #ref $build;
    $test->{build} = $build;
    ($test->{canonical}) = $Module::Build::VERSION =~ m/(\d+\.\d{2})/;
};

sub do_create_meta : Test(7) {
    my $test = shift;

    my $build = $test->{build};
    my $yaml = $test->{yaml};
    my $package = $test->{package};
    my $version = $test->{version};
    my $canonical_version = $test->{canonical};
    
    ok($build->metafile('t/testMETA.yml'), 'setting META file name to testMETA.yml');

    ok($build->do_create_metafile, 'creating META file');

    my $meta = $yaml->read($build->metafile)->[0];

    like($meta->{generated_by}, qr/\A$package version \d+\.\d+\z/, q[asserting 'generated_by']);
    
    like($meta->{generated_by}, qr/\A$package version $version\z/, q[asserting 'generated_by']);

    ok(my $req = $meta->{configure_requires}, q[checking 'configure_requires']);
    
    like($req->{$package}, qr/\A\d+\.\d+\z/, 'asserting version number format');
    
    is($req->{$package}, $canonical_version, 'asserting version against canonical version');

    $test->{file} = $build->metafile;
};

1;

__END__


sub create_mymeta : Test(8) {
    my $test = shift;
    
    my $build = $test->{build};
    my $yaml = $test->{yaml};
    my $package = $test->{package};
    my $version = $test->{version};
    my $canonical_version = $test->{canonical};

    ok($build->metafile('t/testMETA.yml'), 'setting META file name to testMETA.yml');
    ok($build->mymetafile('t/testMYMETA.yml'), 'setting MYMETA file name to testMYMETA.yml');

    ok($build->create_mymeta(), 'creating MYMETA file');

    my $mymeta = $yaml->read($build->mymetafile)->[0];

    like($mymeta->{generated_by}, qr/\A$package version \d+\.\d+\z/, q[asserting 'generated_by']);

    like($mymeta->{generated_by}, qr/\A$package version $version\z/, q[asserting 'generated_by']);

    ok(my $req = $mymeta->{configure_requires}, q[checking 'configure_requires']);

    like($req->{$package}, qr/\A\d+\.\d+\z/, 'asserting version number format');
    
    is($req->{$package}, $canonical_version, 'asserting version against canonical version');
    
    $test->{file} = $build->mymetafile;
};

sub teardown : Test(teardown) {
    my $test = shift;
    
    my $file = $test->{file};
    my $build = $test->{build};
    
    unlink($file) or die "Unable to remove file: $file - $!";
    
    $build->dispatch('realclean');
};

1;
