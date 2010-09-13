package Test::Class::Module::Build::Bundle::Contents;

# $Id$

use strict;
use warnings;
use Test::More;
use File::Copy qw(cp);

use base qw(Test::Class);

use FindBin;
use lib "$FindBin::Bin/../t";

sub setup : Test(setup => 2) {
    my $test = shift;
    
    use_ok('Module::Build::Bundle');
    
    ok(my $build = Module::Build::Bundle->new(
        module_name  => 'Dummy',
        dist_version => '6.66',
        dist_author  => 'jonasbn',
        dist_abstract => 'this is a dummy',
        requires => {
            'Module::Build' => '0.36',
        },
    ), 'calling constructor');

    $test->{build} = $build;
    $test->{file} = 'Dummy.pm';
    
    cp("t/$test->{file}", "$test->{file}")
        or die "Unable to copy file: $test->{file} - $!";
};

sub contents : Test(1) {
    my $test = shift;
    
    my $build = $test->{build};
    
    ok($build->ACTION_contents);
};

sub extended : Test(1) {
    my $test = shift;
    
    my $build = $test->{build};
    
    #HACK: we cheat and pretend to be 5.12.0
    $Module::Build::Bundle::myPERL_VERSION = 5.12.0;
    
    ok($build->ACTION_contents);
};

sub teardown : Test(teardown) {
    my $test = shift;
    
    my $file = $test->{file};
    
    unlink($file) or die "Unable to remove file: $file - $!";
}

1;
