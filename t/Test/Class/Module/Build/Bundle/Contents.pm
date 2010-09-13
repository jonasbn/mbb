package Test::Class::Module::Build::Bundle::Contents;

# $Id$

use strict;
use warnings;
use Test::More;
use File::Copy qw(cp);
use Test::Exception;

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
            'Module::Build' => '0',
        },
    ), 'calling constructor');

    $test->{build} = $build;
    $test->{file} = 'Dummy.pm';
    
    cp("t/$test->{file}", "$test->{file}")
        or die "Unable to copy file: $test->{file} - $!";
};

sub contents : Test(3) {
    my $test = shift;
    
    use_ok('Module::Build::Bundle');
    
    ok(my $build = Module::Build::Bundle->new(
        module_name  => 'Dummy',
        dist_version => '6.66',
        dist_author  => 'jonasbn',
        dist_abstract => 'this is a dummy',
        requires      => {
            'Module::Build' => '0',
            'Module::Info'  => '0.31',
        }
    ), 'calling constructor');

    ok($build->ACTION_contents);

    $test->{build} = $build;
};

sub extended : Test(1) {
    my $test = shift;
    
    my $build = $test->{build};
    
    #HACK: we cheat and pretend to be 5.12.0
    $Module::Build::Bundle::myPERL_VERSION = 5.12.0;
    
    ok($build->ACTION_contents);
};

sub death_by_section_header : Test(1) {
    my $test = shift;
    
    my $build = $test->{build};
    $build->notes('section_header' => 'TO DEATH');
        
    dies_ok { $build->ACTION_contents } 'Unable to replace section';
};

sub section_header : Test(2) {
    my $test = shift;

    ok(my $build = Module::Build::Bundle->new(
        module_name  => 'Dummy2',
        dist_version => '6.66',
        dist_author  => 'jonasbn',
        dist_abstract => 'this is a dummy',
        requires => {
            'Module::Build' => '0.36',
        },
    ), 'calling constructor');
    
    $build->notes('section_header' => 'DEPENDENCIES');

    $test->{file} = 'Dummy2.pm';
    
    cp("t/$test->{file}", "Dummy2.pm")
        or die "Unable to copy file: $test->{file} - $!";

    ok($build->ACTION_contents);
    
    $test->{build} = $build;
};


sub teardown : Test(teardown) {
    my $test = shift;
    
    my $file = $test->{file};
    my $build = $test->{build};
    
    unlink($file) or die "Unable to remove file: $file - $!";
    
    $build->notes('section_header' => '');
}

1;
