
use Test::More tests => 2;

BEGIN { use_ok( 'YAML::Object' ); }

my $yo = yaml_object({});
isa_ok($yo, 'YAML::Object');

