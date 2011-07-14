#!/usr/bin/perl
use strict; use warnings;
use Test::More;

use_ok('Net::SSH::Perl::WithSocks');

my $ssh1 = Net::SSH::Perl::WithSocks->new(
  'motherbrain.nanabox.net',
  WithSocks => {
    SocksHost => 'motherbrain.nanabox.net',
    SocksPort => 9000 } );

ok( defined($ssh1), "Got \$ssh1 ok." );

$ssh1->login('test', 'test') or fail("\$ssh1->login");

# Sanity tests.
my( $stdout1, $stderr1, $exit1 ) = $ssh1->cmd("cat a-file");
my( $stdout2, $stderr2, $exit2 ) = $ssh1->cmd("notacmd");

is( $stdout1, "contents of a-file\n", "Got a-file ok.");
is( $stderr2, "sh: notacmd: not found\n", "Got stderr ok.");

done_testing();
