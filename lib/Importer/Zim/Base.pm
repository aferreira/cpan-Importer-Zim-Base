
package Importer::Zim::Base;

# ABSTRACT: Base module for Importer::Zim backends

use 5.010001;

use Module::Runtime ();

use Importer::Zim::Utils qw(DEBUG carp croak);

sub _prepare_args {
    my $class   = shift;
    my $package = shift
      or croak qq{Usage: use $class MODULE => [\%OPTS =>] EXPORTS...\n};

    my $opts = _module_opts( ref $_[0] eq 'HASH' ? shift : {} );
    my @version = exists $opts->{-version} ? ( $opts->{-version} ) : ();
    &Module::Runtime::use_module( $package, @version );

    my $can_export;
    $can_export = _can_export($package) if $opts->{-strict};

    my ( @exports, %seen );
    @_ = @{"${package}::EXPORT"} unless @_ || !${"${package}::"}{'EXPORT'};
    while (@_) {
        my @symbols = _expand_symbol( $package, shift );
        my $opts = _import_opts( ref $_[0] eq 'HASH' ? shift : {}, $opts );
        for my $symbol (@symbols) {
            croak qq{"$symbol" is not exported by "$package"}
              if $can_export && !$can_export->{$symbol};
            croak qq{Can't handle "$symbol"}
              if $symbol =~ /^[\$\@\%\*]/;
            my $sub    = *{"${package}::${symbol}"}{CODE};
            my $export = do {
                local $_ = $opts->{-as} // $symbol;
                exists $opts->{-map} ? $opts->{-map}->() : $_;
            };
            croak qq{Can't find "$symbol" in "$package"}
              unless $sub;
            my $seen = $seen{$export}{$sub}++;
            croak qq{Can't import as "$export" twice}
              if keys %{ $seen{$export} } > 1;
            unless ($seen) {
                warn(qq{  Importing "${package}::${symbol}" as "$export"\n})
                  if DEBUG;
                push @exports, { export => $export, code => $sub };
            }
        }
    }
    return @exports;
}

sub _module_opts {
    state $IS_MODULE_OPTION
      = { map { ; "-$_" => 1 } qw(how map prefix strict version) };

    my %opts = ( -strict => !!1 );
    my $o = $_[0];
    $opts{-strict} = !!$o->{-strict} if exists $o->{-strict};
    exists $o->{-map} and $opts{-map} = $o->{-map}
      or exists $o->{-prefix} and $opts{-map} = sub { $o->{-prefix} . $_ };
    if ( my @bad = grep { !$IS_MODULE_OPTION->{$_} } keys %$o ) {
        carp qq{Ignoring unknown module options (@bad)\n};
    }
    return \%opts;
}

# $opts = _import_opts($opts1, $m_opts);
sub _import_opts {
    state $IS_IMPORT_OPTION = { map { ; "-$_" => 1 } qw(as map prefix) };

    my %opts;
    exists $_[1]{-map} and $opts{-map} = $_[1]{-map};
    my $o = $_[0];
    $opts{-as} = $o->{-as} if exists $o->{-as};
    exists $o->{-map} and $opts{-map} = $o->{-map}
      or exists $o->{-prefix} and $opts{-map} = sub { $o->{-prefix} . $_ };
    if ( my @bad = grep { !$IS_IMPORT_OPTION->{$_} } keys %$o ) {
        carp qq{Ignoring unknown symbol options (@bad)\n};
    }
    return \%opts;
}

sub _expand_symbol {
    return $_[1] unless ref $_[1] || $_[1] =~ /^[:&]/;

    return map { /^&/ ? substr( $_, 1 ) : $_ } @{ $_[1] } if ref $_[1];

    return substr( $_[1], 1 ) if $_[1] =~ /^&/;

    my ( $package, $tag ) = ( $_[0], substr( $_[1], 1 ) );
    my $symbols
      = ${"${package}::"}{'EXPORT_TAGS'} && ${"${package}::EXPORT_TAGS"}{$tag}
      or return $_[1];
    return map { /^&/ ? substr( $_, 1 ) : $_ } @$symbols;
}

sub _can_export {
    my $package = shift;
    my %exports;
    for (
        ( ${"${package}::"}{'EXPORT'}    ? @{"${package}::EXPORT"}    : () ),
        ( ${"${package}::"}{'EXPORT_OK'} ? @{"${package}::EXPORT_OK"} : () )
      )
    {
        my $x = /^&/ ? substr( $_, 1 ) : $_;
        $exports{$x}++;
    }
    return \%exports;
}

no Importer::Zim::Utils qw(DEBUG carp croak);

1;

=encoding utf8

=head1 DESCRIPTION

   "The Earth is safe once more, GIR! Now let's go destroy it!"
     – Zim

No public interface.

=head1 DEBUGGING

You can set the C<IMPORTER_ZIM_DEBUG> environment variable
for get some diagnostics information printed to C<STDERR>.

    IMPORTER_ZIM_DEBUG=1

=head1 SEE ALSO

L<Importer::Zim>

=cut
