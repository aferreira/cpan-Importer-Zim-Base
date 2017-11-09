
package Importer::Zim::Bogus;

# ABSTRACT: Bogus Importer::Zim backend

use 5.010001;

use Importer::Zim::Utils qw(DEBUG carp);

sub import {
    carp
      qq{WARNING! Using bogus Importer::Zim backend (you may need to install a proper backend)};

    require Importer::Zim::Base;
    goto &Importer::Zim::Base::import_into;
}

sub export_to {
    my $t = shift;
    @_ = %{ $_[0] } if @_ == 1 && ref $_[0] eq 'HASH';
    @_ = map { $_ & 1 ? $_[$_] : "${t}::$_[$_]" } 0 .. $#_;
    goto &_export_to;
}

sub _export_to {
    my %imports = @_;

    no strict 'refs';
    for ( keys %imports ) {
        *$_ = $imports{$_};
    }
}

no Importer::Zim::Utils qw(DEBUG carp);

1;

=encoding utf8

=head1 SYNOPSIS

    use Importer::Zim::Bogus 'Scalar::Util' => 'blessed';
    use Importer::Zim::Bogus 'Scalar::Util' =>
      ( 'blessed' => { -as => 'typeof' } );

    use Importer::Zim::Bogus 'Mango::BSON' => ':bson';

    use Importer::Zim::Bogus 'Foo' => { -version => '3.0' } => 'foo';

    use Importer::Zim::Bogus 'Krazy::Taco' => qw(tacos burritos poop);

=head1 DESCRIPTION

   "Is it supposed to be stupid?"
     – Zim

This is a fallback backend for L<Importer::Zim>.
Only used when you have no installed legit backend.
It does no cleaning at all – so it is a polluting module such
as the regular L<Exporter>.

The reason it exists is to provide a "working" L<Importer::Zim>
after installing L<Importer::Zim> and its nominal dependencies.
It will annoy you with warnings until a proper backend is installed.

=head1 DEBUGGING

You can set the C<IMPORTER_ZIM_DEBUG> environment variable
for get some diagnostics information printed to C<STDERR>.

    IMPORTER_ZIM_DEBUG=1

=head1 SEE ALSO

L<Importer::Zim>

=cut
