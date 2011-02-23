use strict;
use warnings;

use Test::More;
use Sub::Override;

use FixMyStreet;

use_ok 'FixMyStreet::Cobrand';

# check that the allowed cobrands is correctly loaded from config
{
    my $allowed = FixMyStreet::Cobrand->get_allowed_cobrands;
    ok $allowed,     "got the allowed_cobrands";
    isa_ok $allowed, "ARRAY";
    cmp_ok scalar @$allowed, '>', 1, "got more than one";
    is join( '|', @$allowed ), FixMyStreet->config('ALLOWED_COBRANDS'),
      "matches config value";
}

# fake the allowed cobrands for testing
my $override = Sub::Override->new(    #
    'FixMyStreet::Cobrand::get_allowed_cobrands' =>
      sub { return ['emptyhomes'] }
);
is_deeply FixMyStreet::Cobrand->get_allowed_cobrands, ['emptyhomes'],
  'overidden get_allowed_cobrands';

sub run_host_tests {
    my %host_tests = @_;
    for my $host ( sort keys %host_tests ) {
        is FixMyStreet::Cobrand->get_class_for_host($host),
          "FixMyStreet::Cobrand::$host_tests{$host}",
          "does $host -> F::C::$host_tests{$host}";
    }
}

# get the cobrand class by host
run_host_tests(
    'www.fixmystreet.com'    => 'Default',
    'reportemptyhomes.com'   => 'EmptyHomes',
    'barnet.fixmystreet.com' => 'Default',    # not in the allowed_cobrands list
    'some.odd.site.com'      => 'Default',
);

# now enable barnet too and check that it works
$override->replace(                           #
    'FixMyStreet::Cobrand::get_allowed_cobrands' =>
      sub { return [ 'emptyhomes', 'barnet' ] }
);

# get the cobrand class by host
run_host_tests(
    'www.fixmystreet.com'  => 'Default',
    'reportemptyhomes.com' => 'EmptyHomes',
    'barnet.fixmystreet.com' => 'Barnet',  # found now it is in allowed_cobrands
    'some.odd.site.com'      => 'Default',
);

# check that the moniker works as expected both on class and object.
is FixMyStreet::Cobrand::EmptyHomes->moniker, 'emptyhomes',
  'class->moniker works';
is FixMyStreet::Cobrand::EmptyHomes->new->moniker, 'emptyhomes',
  'object->moniker works';

# all done
done_testing();