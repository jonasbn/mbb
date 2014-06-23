#!/usr/bin/env perl

use strict;
use warnings;

use File::Tempdir;


my $dir = f2();

f($dir);

my $tmpdir = f3();

f($tmpdir);

exit 0;

sub f {
    my $indir = shift;

    my $dir;
    if (ref $indir) {
        $dir = $indir->name; 
    } else {
        $dir = $indir;
    }

    if (-e $dir) {
        print "Directory exists\n";
    } else {
        print "Directory do not exist\n";
    }
}

sub f2 {
    my $tmpdir = File::Tempdir->new(CLEANUP => 1);

    print STDERR "Our dir: ", $tmpdir->name, "\n";

    my $dir = $tmpdir->name;

    return $dir;
}

sub f3 {
    my $tmpdir = File::Tempdir->new(CLEANUP => 1);

    print STDERR "Our dir: ", $tmpdir->name, "\n";

    return $tmpdir;
}