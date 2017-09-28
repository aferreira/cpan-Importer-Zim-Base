
package Importer::Zim::Utils;

# ABSTRACT: Utilities for Importer::Zim backends

use 5.010001;

our @EXPORT_OK = qw(DEBUG carp croak);

sub DEBUG () { $ENV{IMPORTER_ZIM_DEBUG} || 0 }

sub carp  { require Carp; goto &Carp::carp; }
sub croak { require Carp; goto &Carp::croak; }

### import / unimport machinery

sub USE_LEXICAL_SUBS () {    # Is Sub::Inject loaded?
    require Module::Runtime;
    return !!$INC{ Module::Runtime::module_notional_filename('Sub::Inject') };
}

sub import {
    my $exports = shift->_get_exports(@_);

    if (USE_LEXICAL_SUBS) {
        @_ = ($exports);
        goto &Sub::Inject::sub_inject;
    }

    my $caller = caller;
    *{ $caller . '::' . $_ } = $exports->{$_} for keys %$exports;
}

sub unimport {
    my $exports = shift->_get_exports(@_);

    return if USE_LEXICAL_SUBS;

    my $caller = caller;
    delete ${"${caller}::"}{$_} for keys %$exports;
}

# BEWARE! unimport() will nuke the entire glob associated to
# an imported subroutine (if USE_LEXICAL_SUBS is false).
# So don't use scalar / hash / array variables with the same
# names as any of the symbols in @EXPORT_OK in the user modules.

sub _get_exports {
    my $class = shift;

    state $EXPORTABLE = { map { $_ => \&{$_} } @EXPORT_OK };

    my ( %exports, @bad );
    for (@_) {
        push( @bad, $_ ), next unless my $sub = $EXPORTABLE->{$_};
        $exports{$_} = $sub;
    }
    if (@bad) {
        my @carp;
        push @carp, qq["$_" is not exported by the $class module\n] for @bad;
        croak(qq[@{carp}Can't continue after import errors]);
    }
    return \%exports;
}

1;

=encoding utf8

=head1 SYNOPSIS

    use Importer::Zim::Utils qw(DEBUG carp croak);
    ...
    no Importer::Zim::Utils qw(DEBUG carp croak);

=head1 DESCRIPTION

No public interface.

=head1 SEE ALSO

L<Importer::Zim>

=cut
