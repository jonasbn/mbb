package Test::Class::Module::Build::Regression;

# $Id$

use strict;
use warnings;
use Test::More;
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

    $test->{version} = $Module::Build::VERSION;
    $test->{package} = ref $build;
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
    
    ok($build->metafile('t/META.yml'));

    ok($build->do_create_metafile);

    my $meta = $yaml->read($build->metafile)->[0];

    like($meta->{generated_by}, qr/\A$package version \d+\.\d+\z/);
    
    like($meta->{generated_by}, qr/\A$package version $version\z/);

    ok(my $req = $meta->{configure_requires});
    
    like($req->{$package}, qr/\A\d+\.\d+\z/);
    
    is($req->{$package}, $canonical_version);

    $test->{file} = $build->metafile;
};

sub create_mymeta : Test(7) {
    my $test = shift;
    
    my $build = $test->{build};
    my $yaml = $test->{yaml};
    my $package = $test->{package};
    my $version = $test->{version};
    my $canonical_version = $test->{canonical};
    
    ok($build->mymetafile('t/MYMETA.yml'));

    ok($build->create_mymeta());

    my $meta = $yaml->read($build->mymetafile)->[0];

    like($meta->{generated_by}, qr/\A$package version \d+\.\d+\z/);

    like($meta->{generated_by}, qr/\A$package version $version\z/);

    ok(my $req = $meta->{configure_requires});

    like($req->{$package}, qr/\A\d+\.\d+\z/);
    
    is($req->{$package}, $canonical_version);
    
    $test->{file} = $build->mymetafile;
};

sub teardown : Test(teardown) {
    my $test = shift;
    
    my $file = $test->{file};
    
    unlink($file) or die "Unable to remove file: $file - $!";
};

1;
