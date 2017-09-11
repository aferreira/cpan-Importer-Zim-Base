
package Importer::Zim::Base;

use 5.018;
no strict 'refs';

use Carp            ();
use Module::Runtime ();

use constant DEBUG => $ENV{IMPORTER_ZIM_DEBUG} || 0;

sub _prepare_args {
    my $class   = shift;
    my $package = shift
      or Carp::croak qq{Usage: use $class MODULE => [\%OPTS =>] EXPORTS...\n};

    my $opts = ref $_[0] ? shift : {};
    my @version = exists $opts->{-version} ? ( $opts->{-version} ) : ();
    &Module::Runtime::use_module( $package, @version );

    my $strict = 1;
    $strict = $opts->{-strict} if exists $opts->{-strict};
    my $can_export;
    $can_export = _can_export($package) if $strict;

    my ( @exports, %seen );
    @_ = @{"${package}::EXPORT"} unless @_ || !${"${package}::"}{'EXPORT'};
    while (@_) {
        my @symbols = _expand_symbol( $package, shift );
        my $opts = ref $_[0] ? shift : {};
        for my $symbol (@symbols) {
            Carp::croak qq{"$symbol" is not exported by the $package module}
              if $can_export && !$can_export->{$symbol};
            my $sub = *{"${package}::${symbol}"}{CODE};
            my $export = $opts->{-as} // $symbol;
            Carp::croak qq{Can't find "$symbol" in "$package"}
              unless $sub;
            my $seen = $seen{$export}{$sub}++;
            Carp::croak qq{Can't import as "$export" twice}
              if keys %{ $seen{$export} } > 1;
            unless ($seen) {
                warn(qq{Importing "${package}::${symbol}" as "$export"\n})
                  if DEBUG;
                push @exports, { export => $export, code => $sub };
            }
        }
    }
    return @exports;
}

sub _expand_symbol {
    return $_[1] unless $_[1] =~ /^:/;

    my ( $package, $tag ) = ( $_[0], substr( $_[1], 1 ) );
    my $symbols
      = ${"${package}::"}{'EXPORT_TAGS'} && ${"${package}::EXPORT_TAGS"}{$tag}
      or return $_[1];
    return @$symbols;
}

sub _can_export {
    my $package = shift;
    my %exports;
    $exports{$_}++
      for (
        ( ${"${package}::"}{'EXPORT'}    ? @{"${package}::EXPORT"}    : () ),
        ( ${"${package}::"}{'EXPORT_OK'} ? @{"${package}::EXPORT_OK"} : () )
      );
    return \%exports;
}

1;

=encoding utf8

=head1 NAME

Importer::Zim::Base - Base module for Importer::Zim

=head1 DESCRIPTION

No public interface.

=head1 DEBUGGING

You can set the C<IMPORTER_ZIM_DEBUG> environment variable
for get some diagnostics information printed to C<STDERR>.

    IMPORTER_ZIM_DEBUG=1

=head1 SEE ALSO

L<Importer::Zim>

=cut
