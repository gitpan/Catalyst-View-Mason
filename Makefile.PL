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

package MY;

sub postamble {
    return <<"EOM"
testcover:
\tHARNESS_PERL_SWITCHES=-MDevel::Cover PERL_DL_NONLAZY=1 \$(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness(\$(TEST_VERBOSE), 'inc', '\$(INST_LIB)', '\$(INST_ARCHLIB)')" \$(TEST_FILES)
\tcover
EOM
}
