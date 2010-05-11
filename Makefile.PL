use inc::Module::Install;

name q(YAML-Object);
all_from q(lib/YAML/Object.pm);

requires q(Symbol) => 1.07;
requires q(YAML) => 0.71;
test_requires q(Test::More) => 0.92;

bugtracker 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=YAML-Object';
homepage 'http://search.cpan.org/dist/YAML-Object';
repository 'git://github.com/jhthorsen/yaml-object.git';

auto_install;
WriteAll;
