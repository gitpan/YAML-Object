use inc::Module::Install;
name q(YAML-Object);
all_from q(lib/YAML/Object.pm);
requires q(Symbol) => 1.0;
requires q(YAML) => 0.70;
test_requires q(Test::More) => 0.9;
auto_insall;
WriteAll;
