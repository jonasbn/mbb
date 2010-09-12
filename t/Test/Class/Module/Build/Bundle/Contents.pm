package Test::Class::Module::Build::Bundle::Contents;

# $Id$

use strict;
use warnings;

use base qw(Test::Class);

use FindBin;
use lib "$FindBin::Bin/../lib";

sub contents : Test(1) {
    my $test = shift;
    
    my $build = $test->{build};
    
    $build->ACTION_contents;
};

1;
