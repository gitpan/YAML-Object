
#===========================
package YAML::Object::Array;
#===========================

use warnings;
use strict;
use overload(
    '@{}'    => sub { shift->{'array'} },
    fallback => 1,
);

sub ___get___key { #==========================================================

    my $self = shift;
    my $name = $self->{'key'};

    if($self->{'parent'}) {
        $name = join "->", $self->{'parent'}->___get___key, $name;
    }

    return $name;
}

#====================
package YAML::Object;
#====================

use warnings;
use strict;
use YAML;
use constant OBJECT => 0;
use constant PARENT => 1;
use constant KEY    => 2;
use overload(
    '%{}'    => sub { shift->[OBJECT] },
    '${}'    => sub { shift->[OBJECT] },
    '""'     => sub { shift->[OBJECT] },
    fallback => 1,
);

our $VERSION = '0.01';
our $AUTOLOAD;


sub LOAD { #==================================================================

    my $self = shift;
    my $file = shift;
    my $yaml = "";

    ### constructor
    $self = bless [{}, undef, ''], $self unless(ref $self);

    ### open
    if($file and -r $file) {
        open(my $fh, "<", $file) or die "Could not read YAML: $!";

        LINE:
        while(my $line = readline $fh) {
            next LINE if($line =~ /^\s*\-{3}/);
            next LINE if($line =~ /^\s*#/);
            next LINE if($line =~ /^\s*$/);
            $yaml .= $line;
        }
        close $fh;

        ### load config
        if(my $config = Load($yaml)) {
            $self->[OBJECT]{$_} = $config->{$_} for(keys %$config);
        }
    }

    ### return object
    return $self;
}

sub ___get___key { #==========================================================

    my $self = shift;
    my $name = $self->[KEY];

    if($self->[PARENT]) {
        $name = join "->", $self->[PARENT]->___get___key, $name;
    }

    return $name;
}

sub AUTOLOAD { #==============================================================

    my $self = shift;
    my $set  = shift;

    return if($AUTOLOAD =~ /::DESTROY$/);

    if($AUTOLOAD =~ /::(\w+)$/mx) {
        my $key = $1;
        my $sub;

        ### cannot get node-data on undef parent node
        unless(defined $self->[OBJECT]) {
            my $name = $self->___get___key ."->$key";
            die "YAML::Object: $name does not exist\n";
        }

        ### hash node
        elsif(ref $self->[OBJECT]{$key} eq 'HASH') {
            $sub = sub {
                       bless [
                          $self->[OBJECT]{$key},
                          $self,
                          $key,
                       ], "YAML::Object";
                   };
        }

        ### list node
        elsif(ref $self->[OBJECT]{$key} eq 'ARRAY') {
            $sub = sub {
                       bless {
                           array  => $self->[OBJECT]{$key},
                           parent => $self,
                           key    => $key,
                       }, "YAML::Object::Array";
                   };
        }

        ### scalar node
        elsif(defined $self->[OBJECT]{$key}) {
            $sub = sub { $self->[OBJECT]{$key} };
        }

        ### undef node
        else {
            $sub = sub {
                       bless [
                          undef,
                          $self,
                          $key,
                       ], "YAML::Object";
                   };
        }

        ### add method
        {
            no strict 'refs';
            *{$AUTOLOAD} = $sub;
        }

        ### return value
        return $self->$AUTOLOAD;
    }

    return;
}

#=============================================================================
1983;
__END__

=head1 NAME

YAML::Object

=head1 VERSION

0.01

=head1 SYNOPSIS

    ### create object
    my $cfg = YAML::Object->LOAD('path/to/my.yaml');

    ### merge path/to/another/file.yaml with existing config-file
    $cfg->LOAD('path/to/another/file.yaml');

=head1 NOTES

The YAML-document cannot have a key named "LOAD", since it will interfere
with the C<LOAD()> method.

=head1 METHODS

=head2 C<LOAD>

As class-method:
Object constructor. Takes one argument, which is the config-filename. This
argument is passed on to C<LOAD()>;

As object-method:
Loads a file and merges it to %$self. Meaning that you can call C<LOAD> as many
times you want. The last loaded YAML-file will override any existing params,
if there are duplicates.

=head2 %{} or @{}

The object is overloaded to return a hash or array.

=head2 ""

The object returns "HASH" or "ARRAY" in string content

=head2 "Everything else"

All other methods returns either:

=over 4

=item YAML::Object object

...a YAML::Object object, if the config-element points on a hash.

This object is overloaded by %{}.

=item YAML::Object::Array object

...a YAML::Object::Array object, if the config-element points on an array.

This object is overloaded by @{}.

=item scalar

...a scalar if that's what it points at.

=back

=head1 AUTHOR

Jan Henning Thorsen, C<< <pm at flodhest.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-pm at flodhest.net>, or through the web interface at
L<http://trac.flodhest.net/pm>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc YAML::Object

You can also look for information at: L<http://trac.flodhest.net/pm>

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jan Henning Thorsen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
