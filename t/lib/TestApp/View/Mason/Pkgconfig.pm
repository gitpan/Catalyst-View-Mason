package TestApp::View::Mason::Pkgconfig;

use strict;
use warnings;
use base 'Catalyst::View::Mason';

__PACKAGE__->config(
        allow_globals => [qw/$foo @bar/],
);

1;
