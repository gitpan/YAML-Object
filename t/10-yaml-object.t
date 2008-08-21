
use warnings;
use strict;
use Test::More tests => 14 * 4;
use YAML::Object;

my %args = (
    file       => q(./t/test.yml),
    string     => q(),
    filehandle => \*DATA,
    hash       => undef,
);

my $offset = tell DATA;
$YAML::Object::yaml_ok->() and $args{'string'} .= $_ while(<DATA>);
seek DATA, $offset, 0;

for my $arg (sort keys %args) {

    is($arg, $arg, "======> $arg");

    my $cfg = yaml_object($args{$arg});

    $args{'hash'} ||= \%{ $cfg };

    ### structure
    is(ref $cfg, "YAML::Object",
        "Config is loaded");
    is(ref $cfg->foo, "YAML::Object",
        "foo is a YAML::Object");

    ### plain values
    is($cfg->foo->hello_world, "HELLO WORLD!",
        "foo->hello_world contains 'HELLO WORLD!'");
    is($cfg->fooooooo, undef,
        "fooooooo is undef");

    ### exception
    eval { $cfg->foo->bar3->bar4 };
    is($@, "YAML::Object: ->foo->bar3->bar4 does not exist\n",
        "Correct error: $@");

    ### hash
    is(int(keys %{ $cfg->foo }), 6,
        "Correct amount of key/value pairs in ->foo hash");

    ### array
    is(ref $cfg->foo->arr_ref, "YAML::Object",
        "foo->arr_ref is a YAML::Object object");

    is(int(@{ $cfg->foo->arr_ref }), 5,
        "Correct amount of elements in ->foo->arr_ref array");

    for my $i (0..3) {
        is($cfg->foo->arr_ref->$i, "element $i",
            "foo->arr_ref->$i contains 'element $i'");
    }

    is($cfg->foo->arr_ref->_4___->b, "2",
        "foo->arr_ref->_4->b contains '2'");
}

__DATA__

foo:
    a: 0a0a0a0a
    b: 0b0b0b0b
    c: 0c0c0c0c
    d: 0d0d0d0d

    ### this is a comment
    arr_ref:
       - element 0
       - element 1
       - element 2
       - element 3
       -
           a: 1
           b: 2

    --- this is another comment
    hello_world: HELLO WORLD!

