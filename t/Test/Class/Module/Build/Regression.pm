package Test::Class::Module::Build::Regression;

# $Id$

use strict;
use warnings;
use Test::More;
use Module::Build::YAML;

use FindBin;
use lib "$FindBin::Bin/../t";

use base qw(Test::Class Test::Class::Module::Build::Bundle);

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

1;
