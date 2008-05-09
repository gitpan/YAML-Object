
use YAML::Object;
use Test::More tests => 8;

my $cfg = YAML::Object->LOAD("./t/test.yml");

is(ref $cfg, 'YAML::Object', 'Config is not correctly loaded');
is(ref $cfg->foo, 'YAML::Object', 'Node is not a YAML::Object');
is(ref $cfg->foo->bar1, 'YAML::Object::Array', 'Node is not a YAML::Object::Array');

my %hash  = %{ $cfg->foo };
my @array = @{ $cfg->foo->bar1 };
is(int(keys %hash), 2, 'Correct amount of elements in hash');
is(int(@array), 3, 'Correct amount of elements in array');
is($cfg->foo->bar2, "hello world", "Node is not a scalar value");
is($cfg->foo->bar3, undef, "value is not undefined");

eval { $cfg->foo->bar3->bar4 };
is($@, "YAML::Object: ->foo->bar3->bar4 does not exist\n", "Wrong exception");

