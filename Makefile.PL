

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'YAML::Object',
    VERSION_FROM => 'lib/YAML/Object.pm', # finds \$VERSION
    AUTHOR       => 'Jan Henning Thorsen (cpan@flodhest.net)',
    ABSTRACT     => 'Module abstract (<= 44 characters) goes here',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'YAML'         => 0,
                    },
);
