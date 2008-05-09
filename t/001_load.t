# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'YAML::Object' ); }

my $object = YAML::Object->LOAD;
isa_ok ($object, 'YAML::Object');


