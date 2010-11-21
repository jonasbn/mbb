package Test::Class::Module::Build::Bundle;

# $Id$

use strict;
use warnings;
use Test::More;
use Module::Build::YAML;
use Test::MockObject::Extends;
use FindBin;
use lib "$FindBin::Bin/../t";

use base qw(Test::Class Test::Class::Module::Build::Regression);

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

1;
