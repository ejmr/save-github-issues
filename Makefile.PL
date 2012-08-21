use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'App::Github::Issues',
    AUTHOR        => q{Eric James Michael Ritzi <lobbyjones@gmail.com>},
    ABSTRACT_FROM => 'save-github-issues.pl',
    VERSION_FROM  => 'save-github-issues.pl',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'gpl') : ()),
    PREREQ_PM => {
        'LWP'         => 6,
        'JSON'        => 2,
        'DBD::SQLite' => 0,
    },  
    EXE_FILES => ['save-github-issues.pl'],
    META_MERGE => {
        resources => {
            repository => 'https://github.com/squeeks/save-github-issues.git'
        }
    },
);