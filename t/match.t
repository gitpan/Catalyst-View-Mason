#!perl

use strict;
use warnings;
use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/lib";

use TestApp::FakeLog;

{
    no warnings 'once';
    $::setup_match = 1;
    $::fake_log = TestApp::FakeLog->new([]);
}

use_ok('Catalyst::Test', 'TestApp');

my $response = request('/match/foo?view=Match');
ok($response->is_success, 'request ok');
is($response->content, 'foo');
