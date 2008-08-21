use inc::Module::Install;

name     q(YAML-Object);
all_from q(lib/YAML/Object.pm);

requires      q(YAML)       => 0;
test_requires q(Test::More) => 0;

WriteAll;
