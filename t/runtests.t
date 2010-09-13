# $Id$

use strict;
use warnings;

use Test::Class;

use FindBin;
use lib "$FindBin::Bin/../t";

#use Test::Class::Module::Build::Bundle;
use Test::Class::Module::Build::Bundle::Contents;
#use Test::Class::Module::Build::Regression;

Test::Class->runtests();
