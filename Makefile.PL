use strict;
use warnings;
use inc::Module::Install;

name 'Catalyst-View-Mason';
all_from 'lib/Catalyst/View/Mason.pm';
license 'perl';

requires 'Catalyst'     => '5.50';
requires 'HTML::Mason'  => 0;
requires 'Scalar::Util' => 0;
requires 'File::Spec'   => 0;

auto_provides;
extra_tests;

WriteAll;

package MY;

sub postamble {
    my $make_test = q{PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)};

    return <<"EOM"
testcover: pm_to_blib
\t-HARNESS_PERL_SWITCHES=-MDevel::Cover $make_test
\tcover

README: lib/Catalyst/View/Mason.pm
\tpod2text \$< > \$@
EOM
}
