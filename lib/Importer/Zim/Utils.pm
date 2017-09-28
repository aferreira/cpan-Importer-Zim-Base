
package Importer::Zim::Utils;

# ABSTRACT: Utilities for Importer::Zim backends

use 5.010001;

our @EXPORT_OK = qw(DEBUG carp croak);

sub DEBUG () { $ENV{IMPORTER_ZIM_DEBUG} || 0 }

sub carp  { require Carp; goto &Carp::carp; }
sub croak { require Carp; goto &Carp::croak; }

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
