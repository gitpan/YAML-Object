
use warnings;
use strict;
use FindBin;
use Test::More tests => 14 * 4;
use YAML::Object;

my %args = (
    file       => qq($FindBin::Bin/test.yml),
    string     => qq(),
    filehandle => \*DATA,
    hash       => undef,
);

my $offset = tell DATA;
$args{'string'} .= $_ while(<DATA>);
seek DATA, $offset, 0;

for my $arg (sort keys %args) {

    ok($arg, "==> Checking $arg");

    my $cfg = yaml_object($args{$arg});

    $args{'hash'} ||= \%{ $cfg };

    ### structure
    is(ref($cfg), "YAML::Object", "Config is loaded");
    is(ref($cfg->foo), "YAML::Object", "foo is a YAML::Object");

    ### plain values
    is($cfg->foo->hello_world, "HELLO WORLD!",
        "foo->hello_world contains 'HELLO WORLD!'");
    is($cfg->fooooooo, undef, "fooooooo is undef");

    ### exception
    eval { $cfg->foo->bar3->bar4 };
    chomp $@;
    is($@, "YAML::Object: ->foo->bar3->bar4 does not exist",
        "Correct error: $@");

    ### hash
    is(int(keys %{ $cfg->foo }), 6,
        "Correct amount of key/value pairs in ->foo hash");

    ### array
    is(ref $cfg->foo->array_element, "YAML::Object",
        "foo->array_element is a YAML::Object");

    is(int(@{ $cfg->foo->array_element }), 5,
        "Correct amount of elements in ->foo->array_element array");

    for my $i (0..3) {
        is($cfg->foo->array_element->$i, "element $i",
            "foo->array_element->$i contains 'element $i'");
    }

    is($cfg->foo->array_element->_4___->b, "2",
        "foo->array_element->_4->b contains '2'");
}

__DATA__

foo:
  a: 0a0a0a0a
  b: 0b0b0b0b
  c: 0c0c0c0c
  d: 0d0d0d0d

  array_element:
    - element 0
    - element 1
    - element 2
    - element 3
    - a: 1
      b: 2

  hello_world: HELLO WORLD!

