#!perl

use strict;
use warnings;
use Test::More;

plan skip_all => 'set $ENV{TEST_AUTHOR} to enable this test' unless $ENV{TEST_AUTHOR};

eval 'use Test::Spelling';
plan skip_all => 'Test::Spelling required' if $@;

set_spell_cmd('aspell list');

add_stopwords(<DATA>);

all_pod_files_spelling_ok();

__DATA__
Kievsky
Ragwitz
Ramberg
Riedel
