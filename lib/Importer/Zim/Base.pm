
package Importer::Zim::Base;

use 5.018;
no strict 'refs';

use Carp            ();
use Module::Runtime ();

sub _prepare_args {
    my $class   = shift;
    my $package = shift
      or Carp::croak qq{Usage: use $class MODULE => [\%OPTS =>] EXPORTS...\n};

    my $opts = ref $_[0] ? shift : {};
    my @version = exists $opts->{-version} ? ( $opts->{-version} ) : ();
    &Module::Runtime::use_module( $package, @version );

    my @exports;
    while (@_) {
        my @symbols = _expand_symbol( $package, shift );
        my $opts = ref $_[0] ? shift : {};
        for my $symbol (@symbols) {
            my $sub = *{"${package}::${symbol}"}{CODE};
            my $export = $opts->{-as} // $symbol;
            Carp::croak qq{Can't find "$symbol" in "$package"}
              unless $sub;
            push @exports, { export => $export, code => $sub };
        }
    }
    return @exports;
}

sub _expand_symbol {
    return $_[1] unless $_[1] =~ /^:/;

    my ( $package, $tag ) = ( $_[0], substr( $_[1], 1 ) );
    my $symbols = ${"${package}::EXPORT_TAGS"}{$tag}
      or return $_[1];
    return @$symbols;
}

1;

=encoding utf8

=head1 NAME

Importer::Zim::Base - Base module for Importer::Zim

=head1 DESCRIPTION

No public interface.

=cut
