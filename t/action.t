#!perl

use strict;
use warnings;
use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Catalyst::Test', 'TestApp');

my $request = request('/action_match/foo?view=Match');
ok($request->is_success, 'request ok');
