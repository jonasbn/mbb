#!/usr/bin/perl

use strict;
use warnings;

print "bare $^V\n";

printf "printf v%vd\n", $^V;

if ( $^V eq 5.10.0 ) {
    print "We have the same version ($^V)\n";
} elsif ( $^V lt 5.10.0 ) {
    print "We have a version lower than 5.10.0 ($^V)\n";
} elsif ( $^V gt 5.10.0 ) {
    print "We have a version higher than 5.10.0??? ($^V)\n";
}

$^V = 5.12.0;

if ( $^V eq 5.10.0 ) {
    print "We have the same version ($^V)\n";
} elsif ( $^V lt 5.10.0 ) {
    print "We have a version lower than 5.10.0 ($^V)\n";
} elsif ( $^V gt 5.10.0 ) {
    print "We have a version higher than 5.10.0??? ($^V)\n";
}

exit 0;