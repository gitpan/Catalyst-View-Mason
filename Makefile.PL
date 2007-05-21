use strict;
use warnings;
use inc::Module::Install;

name 'Catalyst-View-Mason';
all_from 'lib/Catalyst/View/Mason.pm';

requires 'Catalyst' => '5.50';
requires 'HTML::Mason' => 0;
requires 'Scalar::Util' => 0;
requires 'File::Spec' => 0;

auto_install;
WriteAll;
