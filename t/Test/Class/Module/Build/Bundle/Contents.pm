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
            'Text::Soundex' => '2.00',
        },
    ), 'calling constructor');

    $test->{build} = $build;
    $test->{file} = 'Dummy.pm';
};

sub contents : Test(3) {
    my $test = shift;
    
    my $build = $test->{build};

    cp("t/$test->{file}", "$test->{file}")
        or die "Unable to copy file: $test->{file} - $!";
    
    ok($build->ACTION_contents);
    
    open FIN, '<', $test->{file} or die "Unable to open file: $!";
    my $content = join '', <FIN>;
    close FIN;
    
    like($content, qr/=item \* L<Module::Build\|Module::Build>/s);
    like($content, qr/=item \* L<Text::Soundex\|Text::Soundex>, 2\.00/);

    $test->{build} = $build;
};

sub extended : Test(3) {
    my $test = shift;
    
    my $build = $test->{build};

    cp("t/$test->{file}", "$test->{file}")
        or die "Unable to copy file: $test->{file} - $!";
    
    #HACK: we cheat and pretend to be 5.12.0
    $Module::Build::Bundle::myPERL_VERSION = 5.12.0;
    
    ok($build->ACTION_contents);

    open FIN, '<', $test->{file} or die "Unable to open file: $!";
    my $content = join '', <FIN>;
    close FIN;
    
    like($content, qr/=item \* L<Module::Build\|Module::Build>/s);
    like($content, qr[=item \* L<Text::Soundex\|Text::Soundex>, L<2\.00\|http://search.cpan.org/dist/Text-Soundex-2\.00/Soundex.pm>]);
};

sub death_by_section_header : Test(1) {
    my $test = shift;
    
    my $build = $test->{build};

    cp("t/$test->{file}", "$test->{file}")
        or die "Unable to copy file: $test->{file} - $!";

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
