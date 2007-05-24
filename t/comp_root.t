#!perl

use strict;
use warnings;
use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/lib";

{
    no warnings 'once';
    $::use_root_string = 1;
}

use_ok('Catalyst::Test', 'TestApp', 'foo');

my $response = request('/test?view=Pkgconfig');

ok($response->is_success, 'request ok');
is($response->content, TestApp->config->{default_message}, 'message ok');
