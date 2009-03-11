package YAML::Object;

=head1 NAME

YAML::Object - Use OO to point to a yaml-node

=head1 VERSION

0.04

=head1 SYNOPSIS

 use YAML::Object; # imports yaml_object()

 $yo      = yaml_object($path_to_yaml_file);
 $complex = $yo->foo->bar->_2->a;

 $tmp1 = $yo->does_not_exist;  # $tmp1 will be a YAML::Object
 $tmp2 = $tmp1->try_something; # will die() with message:

C<YAML::Object: ->does_not_exist->try_something does not exist>

The first will succeed, to enable you to test if C<$tmp1> is undef:

 if(defined $tmp1) { ... }

 $tmp3 = $yo->some_hash; # returns a YAML::Object
 $tmp3->{'test'};        # will work, returns a "plain value"
 $tmp3->test;            # same, but will returns a YAML::Object

Both should behave the same way in your code.

 $index = 1;
 $tmp3  = $yo->some_array; # returns a YAML::Object
 $tmp3->[$index];          # will work, returns a "plain value"
 $tmp3->$index;            # same result, but will return a YAML::Object
 $tmp3->_1;                # same result as above

The above should behave the same way in your code.

=cut

use warnings;
use strict;
use Symbol;
use YAML;
use overload (
    q(%{}) => sub {
        my $data = $_[0]->()->[0];
        return $data if(UNIVERSAL::isa($data, "HASH"));
        return {};
    },
    q(@{}) => sub {
        my $data = $_[0]->()->[0];
        return $data if(UNIVERSAL::isa($data, "ARRAY"));
        return [];
    }, 
    q(*{}) => sub {
        my $s = gensym();
        my $d = $_[0]->()->[0];

        *$s->{ref($d) || 'SCALAR'} = $d;

        return $s;
    },
    q(${}) => sub { $_[0]->()->[0] },
    q("") => sub { $_[0]->()->[0] },
    fallback => 1,
);

our $VERSION = '0.04';
our($AUTOLOAD, $yaml_object, $get_key);

=head1 EXPORTED FUNCTIONS

=head2 yaml_object(string)

Object constructor. Takes one argument, which can be either:

 * A path to a valid YAML-file
 * A filehandle to read YAML data from
 * A valid string, containing valid YAML
 * A hash-ref

Returns a C<YAML::Object> object.

=cut

$yaml_object = sub {
    my $in   = shift;
    my $data = [undef, undef, q()];
    my $yaml = q();
    my $fh;

    unless(defined $in) {
        return sub { $data };
    }
    elsif(ref $in eq 'GLOB') {
        $fh = $in;
    }
    elsif(ref $in eq 'HASH') {
        $data->[0] = $in;
    }
    elsif($in !~ /\n/ and -r $in) {
        open($fh, "<", $in)
            or die "YAML::Object: Could not read yaml-file ($in): $!\n";
    }
    else {
        $yaml = $in;
    }

    if($fh) {
        local $_;
        $yaml .= $_ while(<$fh>);
    }

    if($yaml) {
        $data->[0] = Load($yaml);
    }

    return bless sub { $data };
};

sub AUTOLOAD {
    my $self = shift;
    my($key) = $AUTOLOAD =~ /::(\w+)$/;

    return if($key eq 'DESTROY');

    my $data = $self->()->[0];
    my $next = [undef, $self, $key];

    unless(defined $data) {
        die(sprintf "YAML::Object: %s->%s does not exist\n",
            $get_key->($self), $key,
        );
    }

    if(ref $data eq 'HASH') {
        $next->[0] = $data->{$key};
    }
    elsif(ref $data eq 'ARRAY') {
        $key =~ s/\D//g;

        unless(length $key) {
            $key = $AUTOLOAD =~ /::(\w+)$/;
            die "YAML::Object: '$key' is not numeric!" 
        }

        $next->[0] = $data->[$key];
    }

    return bless sub { $next }, ref $self;
}

sub import {
    no strict 'refs';
    *{caller(0) ."::yaml_object"} = $yaml_object;
}

$get_key = sub {
    my $self = shift;
    my $data = $self->();

    if($data->[1]) {
        return join q(->), $get_key->($data->[1]), $data->[2];
    }
    else {
        return q();
    }
};

=head1 METHODS

All methods called, will map to an element in the YAML-tree or undef / throw
error if not. With two exceptions: AUTOLOAD and import are in use in this
package.

=head1 OVERLOADING

=head2 %{}, @{}, ${}, "", ...

The object is overloaded to return the datatype you expect. The datatype
returned is NOT an object, so you cannot continue calling methods on that.

=head1 OBJECT STRUCTURE

 $self = sub {[ data, parent-object, key ]};

=head1 AUTHOR

Jan Henning Thorsen, C<< <pm at flodhest.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-pm at flodhest.net>, or through the web interface at
L<http://trac.flodhest.net/pm>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jan Henning Thorsen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
