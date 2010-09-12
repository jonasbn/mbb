# $Id$

# $HeadURL$

use strict;
use warnings;
use Test::More qw(no_plan);
use Module::Build::YAML;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Module::Build::Bundle;

ok(my $build = Module::Build::Bundle->new(
    module_name  => 'Dummy',
    dist_version => '6.66',
    dist_author  => 'jonasbn',
    dist_abstract => 'this is a dummy',
), 'calling constructor');

ok($build->metafile('t/META.yml'));

ok($build->do_create_metafile);

my $yaml = Module::Build::YAML->new();

my $meta = $yaml->read($build->metafile)->[0];

like($meta->{generated_by}, qr/\AModule::Build::Bundle version \d+\.\d+\z/);

ok(my $req = $meta->{configure_requires});
is($req->{'Module::Build::Bundle'}, '0.01');

