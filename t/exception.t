#!perl

use strict;
use warnings;
use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Catalyst::Test', 'TestApp');

my $response = request('/exception?view=Pkgconfig');

ok(!$response->is_success, 'request fails');
