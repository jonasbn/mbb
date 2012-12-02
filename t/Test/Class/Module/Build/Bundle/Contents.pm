package Test::Class::Module::Build::Bundle::Contents;

# $Id$

use strict;
use warnings;
use Test::More;
use File::Copy qw(cp);
use Test::Exception;
use File::Tempdir;
use File::Slurp; #read_file

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
	
	my $tmpdir = File::Tempdir->new();
    $test->{tempdir} = $tmpdir;
    $test->{temp_wd} = $tmpdir->name;
    
    chmod '0400', $tmpdir->name
        or die "Unable to change permission for: ".$tmpdir->name;
    
    #this is induced in the code
    $build->notes('temp_wd' => $test->{temp_wd});
    
    if (! -e $test->{temp_wd} or ! -w _) {
        $test->{unfriendly_fs} = 1;
    }
};

sub contents : Test(4) {
    my $test = shift;
    
    my $build = $test->{build};
    
    SKIP: {
        skip "file system is not cooperative", 4, $test->{unfriendly_fs};
    
        unless ($test->{unfriendly_fs}) {
            cp("t/$test->{file}", "$test->{temp_wd}/$test->{file}")
                or die "Unable to copy file: $test->{file} - $!";
        }

        #HACK: we cheat and pretend to be 5.10.1
        $Module::Build::Bundle::myPERL_VERSION = 5.10.1;
    
        ok($build->ACTION_contents, 'executing ACTION_contents');
    
        ok(my $content = read_file( "$test->{temp_wd}/$test->{file}" ), 'reading file contents');
    
        like($content, qr/=item \* L<Module::Build\|Module::Build>/s, 'asserting Module::Build item');
        like($content, qr/=item \* L<Text::Soundex\|Text::Soundex>, 2\.00/, 'asserting Text::Soundex item');

        $test->{build} = $build;
    }
};

sub extended : Test(5) {
    my $test = shift;
    
    my $build = $test->{build};

    SKIP: {
        skip "file system is not cooperative", 5, $test->{unfriendly_fs};
    
        ok(cp("t/$test->{file}", "$test->{temp_wd}/$test->{file}"), 'Copying test file'
                or diag ("Unable to copy file: $test->{file} - $!"));
    
        #HACK: we cheat and pretend to be 5.12.0
        $Module::Build::Bundle::myPERL_VERSION = 5.12.0;
    
        ok($build->ACTION_contents, 'executing ACTION_contents');

        ok(my $content = read_file( "$test->{temp_wd}/$test->{file}" ), 'reading file contents');
        
        like($content, qr/=item \* L<Module::Build\|Module::Build>/s, 'asserting Module::Build item');
        like($content, qr[=item \* L<Text::Soundex\|Text::Soundex>, L<2\.00\|http://search.cpan.org/dist/Text-Soundex-2\.00/lib/Text/Soundex.pm>], 'asserting Text::Soundex item');
    }
};

sub death_by_section_header : Test(2) {
    my $test = shift;
    
    my $build = $test->{build};

    SKIP: {
        skip "file system is not cooperative", 2, $test->{unfriendly_fs};
    
        ok(cp("t/$test->{file}", "$test->{temp_wd}/$test->{file}"), 'Copying test file'
                or diag("Unable to copy file: $test->{temp_wd}/$test->{file} - $!"));
        
        $build->notes('section_header' => 'TO DEATH');
        
        dies_ok { $build->ACTION_contents } 'Unable to replace section';
    }
};

sub section_header : Test(3) {
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
    
    SKIP: {
        skip "file system is not cooperative", 2, $test->{unfriendly_fs};
    
        ok(cp("t/$test->{file}", "$test->{temp_wd}/$test->{file}"), 'Copying test file'
                or diag ("Unable to copy file: $test->{file} - $!"));

        ok($build->ACTION_contents, 'executing ACTION_contents');
    
        $test->{build} = $build;
    }
};


sub teardown : Test(teardown) {
    my $test = shift;
    
    my $file = $test->{file};
    my $build = $test->{build};
    
    #if (-e "$test->{temp_wd}/$file") {
    #
    #    unlink("$test->{temp_wd}/$file") 
    #        or die "Unable to remove file: $test->{temp_wd}/$file - $!";
    #}
    
    #if (-e $test->{temp_wd}) {
    #    rmdir($test->{temp_wd})
    #    	or die "Unable to remove directory: $test->{temp_wd} - $!";
    #}

    $build->notes('section_header' => '');
}

1;
