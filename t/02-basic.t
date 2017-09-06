
use 5.018;
use Test::More;

use Importer::Zim::Base;

{
    my @exports = Importer::Zim::Base->_prepare_args( 'M1' => qw(f1 f2) );
    my @expected = (
        { export => 'f1', code => \&M1::f1 },
        { export => 'f2', code => \&M1::f2 },
    );
    is_deeply( \@exports, \@expected, "prepare 'M1' => qw(f1 f2)" );
}
{
    my @exports = Importer::Zim::Base->_prepare_args(
        'M1' => 'f1' => { -as => 'g1' },
        'f2', 'f3' => { -as => 'h3' }
    );
    my @expected = (
        { export => 'g1', code => \&M1::f1 },
        { export => 'f2', code => \&M1::f2 },
        { export => 'h3', code => \&M1::f3 },
    );
    is_deeply( \@exports, \@expected,
        "prepare 'M1' => 'f1' => { -as => 'g1' }, 'f2', 'f3' => { -as => 'h3' }"
    );
}

done_testing;

package M1;

BEGIN { $INC{'M1.pm'} = __FILE__ }

sub f1 { }
sub f2 { }
sub f3 { }
