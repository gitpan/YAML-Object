
#====================
package YAML::Object;
#====================

use warnings;
use strict;
use YAML;
use overload (
    q(%{})   => sub {
        my $data = &{ $_[0] };
        return $data->[0] if(UNIVERSAL::isa($data->[0], "HASH"));
        return {};
    },
    q(@{})   => sub {
        my $data = &{ $_[0] };
        return $data->[0] if(UNIVERSAL::isa($data->[0], "ARRAY"));
        return [];
    }, 
    q(${})   => sub { return $_[0]->()->[0] },
    q("")    => sub { return $_[0]->()->[0] },
    fallback => 1,
);

our $VERSION = '0.03';
our($AUTOLOAD, $yaml_object, $yaml_ok, $get_key);

$yaml_ok = sub { #============================================================
    return 0 if(/^\s*\-{3}/);
    return 0 if(/^\s*#/);
    return 0 if(/^\s*$/);
    return 1;
};

$yaml_object = sub { #========================================================
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
        open($fh, "<", $in) or die "Could not read yaml-file ($in): $!\n";
    }
    else {
        $yaml = $in;
    }

    if($fh) {
        local $_;
        while($_ = readline $fh) {
            $yaml_ok->() and $yaml .= $_;
        }
    }

    if($yaml) {
        $data->[0] = Load($yaml);
    }

    return bless sub { $data };
};

$get_key = sub { #============================================================
    my $self = shift;
    my $data = $self->();

    if($data->[1]) {
        return join q(->), $get_key->($data->[1]), $data->[2];
    }
    else {
        return q();
    }
};

sub AUTOLOAD { #==============================================================
    my $self = shift;
    my $data = &$self->[0];
    my($key) = $AUTOLOAD =~ /::(\w+)$/mx;
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
        $key       =~ s/\D//g;
        $next->[0] =  $data->[$key];
    }

    return bless sub { $next };
}

sub import { #================================================================
    my $parent = caller(0);
    no strict 'refs';
    *{"${parent}::yaml_object"} = $yaml_object;
}

DESTROY { #===================================================================
}

#=============================================================================
1;
__END__

=head1 NAME

YAML::Object - Use OO to point to a yaml-node

=head1 VERSION

0.03

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

=head1 FUNCTIONS

=head2 yaml_object(string)

Object constructor. Takes one argument, which can be either:

 * A path to a valid YAML-file
 * A filehandle to read YAML data from
 * A valid string, containing valid YAML
 * A hash-ref

Returns a C<YAML::Object> object.

=head1 METHODS

All methods called, will map to an element in the YAML-tree or undef / throw
error if not.

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
