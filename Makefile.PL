use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::View::Mason',
    AUTHOR    => 'Andres N. Kievsky (ank@cpan.org)',
    PREREQ_PM => {
        Catalyst        => '4.00',
		'HTML::Mason'		=> '1.00',
    },
    VERSION_FROM => 'lib/Catalyst/View/Mason.pm'
);

