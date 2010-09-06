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
    create_readme => 1,
    requires      => {
		'Tie::IxHash' => '0',
		'Carp'        => '0',
		'Cwd'         => '0',
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
