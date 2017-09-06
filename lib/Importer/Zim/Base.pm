
package Importer::Zim::Base;

use 5.018;
use Carp ();
use Module::Runtime ();

sub _prepare_args {
    my $class = shift;
    my $package = shift
       or Carp::croak qq{Usage: use $class MODULE => EXPORTS...\n};
    Module::Runtime::require_module($package);

    my @exports;
    while (@_) {
        my $symbol = shift;
        my $opts = ref $_[0] ? shift : { -as => $symbol };
        my $export = $opts->{-as};
        my $sub = do {
            no strict 'refs';
            *{"${package}::${symbol}"}{CODE};
        };
        Carp::croak qq{Can't find "$symbol" in "$package"}
            unless $sub;
        push @exports, { export => $export, code => $sub };
    }
    return @exports;
}

1;

=encoding utf8

=head1 NAME

Importer::Zim::Base - Base module for Importer::Zim

=head1 DESCRIPTION

No public interface.

=cut
