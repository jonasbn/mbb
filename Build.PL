# Build.PL for Module::Build::Bundle

# $Id$

use strict;
use warnings;
use Module::Build;

our $VERSION = '0.01';

my $build = Module::Build->new(
    dist_author   => 'Jonas B. Nielsen (jonasbn), <jonasbn@cpan.org>',
    module_name   => 'Module::Build::Bundle',
    dist_abstract => 'build assistance for Bundle and Task distributions',
    license       => 'artistic',
    create_makefile_pl => 'traditional',
    create_readme => 1,
    build_requires => {
        'Module::Build' => '0',
    },
    requires      => {
        'Carp'             => '0',
        'Cwd'              => '0',
        'English'          => '0',
        'File::Copy'       => '0',       #test
        'File::Slurp'      => '0',
        'FindBin'          => '0',       #test
        'CPAN::Meta::YAML' => '0',       #test
        'Test::Class'      => '0',       #test
        'Test::More'       => '0',       #test
        'Test::Exception'  => '0',       #test
        'File::Tempdir'    => '0',       #test
        'Tie::IxHash'      => '0',
        'perl'             => '5.6.0',
        'Test::MockObject::Extends' => '0', #test
    },
    meta_merge => {
        resources => {
            homepage => 'http://logiclab.jira.com/wiki/display/MBB/Home',
            bugtracker =>
                'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Build-Bundle',
            repository => 'http://logicLAB.jira.com/svn/MBB',
            ProjectChangelog =>
                'http://logiclab.jira.com/browse/MBB#selectedTab=com.atlassian.jira.plugin.system.project%3Achangelog-panel',
            ProjectSite => 'http://logicLAB.jira.com/browse/MBB',
            ProjectWiki => 'http://logiclab.jira.com/wiki/display/MBB/Home',
        }
    },
);

$build->create_build_script();
