#!perl

use strict;
use warnings;
use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Catalyst::Test', 'TestApp');

my $response = request('/match/foo?view=Pkgconfig');
ok($response->is_success, 'request ok');
is($response->content, 'foo');
