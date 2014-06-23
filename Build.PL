# Build.PL for Module::Build::Bundle

use strict;
use warnings;
use Module::Build;

our $VERSION = '0.02';

my $build = Module::Build->new(
    dist_author   => 'Jonas B. Nielsen (jonasbn), <jonasbn@cpan.org>',
    module_name   => 'Module::Build::Bundle',
    dist_abstract => 'build assistance for Bundle and Task distributions',
    license       => 'artistic',
    create_makefile_pl => 'traditional',
    create_readme      => 1,
    configure_requires => { 'Module::Build' => '0.42' },
    test_requires      => {
        'Env'                       => '0',
        'File::Copy'                => '0',
        'File::Slurp'               => '0',
        'File::Tempdir'             => '0',
        'FindBin'                   => '0',
        'CPAN::Meta::YAML'          => '0',
        'Test::Class'               => '0',
        'Test::More'                => '0',
        'Test::Exception'           => '0',
        'File::Tempdir'             => '0',
        'Test::MockObject::Extends' => '0',
    },
    requires => {
        'Carp'          => '0',
        'Cwd'           => '0',
        'English'       => '0',
        'File::Slurp'   => '0',
        'Tie::IxHash'   => '0',
        'perl'          => '5.8.0',
        'Module::Build' => '0.42',
        'Env'                       => '0',
        'File::Copy'                => '0',
        'File::Tempdir'             => '0',
        'FindBin'                   => '0',
        'CPAN::Meta::YAML'          => '0',
        'Test::Class'               => '0',
        'Test::More'                => '0',
        'Test::Exception'           => '0',
        'File::Tempdir'             => '0',
        'Test::MockObject::Extends' => '0',
    },
    meta_merge => {
        resources => {
            homepage => 'https://github.com/jonasbn/MBB',
            bugtracker =>
                'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Build-Bundle',
            repository => 'https://github.com/jonasbn/MBB',
        }
    },
);

$build->create_build_script();
