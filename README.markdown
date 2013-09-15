# save-github-issues

This Perl program can automatically create a database of repository
issues for backup purposes, since Github currently does not provide
that functionality.



# Installation

First download the source into one directory and then run the follow
commands:

    $ perl Makefile.PL
    $ make
    $ make test    # (Optional)
    $ make insall

This will automatically install any Perl modules you do not have that
the program requires, which appear below.



# Required Perl Modules

1. `DBI`
2. `DBD::SQLite`
3. `LWP::UserAgent`
4. `JSON`

The program also requires [SQLite](http://sqlite.org).



# Usage

The program accepts the following arguments, with the short version
shown first followed by the longer version:

1. `-u, --user`: **Required.** This is the user whose owns the
repositories you want issues from.

2. `-r, --repo`: **Optional.** This names the repository whose issues
you want to save.  This option may appear multiple times.  If you do
not provide any `--repo` option then the program will download the
issues for every repository the user owns.

An example:

    $ ./save-github-issues.pl --user ejmr --repo php-mode --repo bbcode-mode
    Saving issues for user ejmr

    Saving issues for php-mode
    Saving issues for bbcode-mode

This creates a file called `issues.sqlite` in the current directory.
It is a database with a single table that has the following columns:

1. `url`: The URL to the issue on Github.

2. `title`: The name of the issue.

3. `type`: A string indicating if the issue is ‘opened’ or ‘closed’,
and so on.

4. `json`: A long string of the raw JSON which Github returns.  This
is useful so you have a complete backup of all of the information
which the Github API provides.



# Other Tools

I have not performed any work on this program for a long time, and I
do not expect to do so in the near future.  That does not mean the
program is dead or abandoned; I will still accept feature ideas and
fix bugs.  But I want to suggest that users also check out the
[hub][3] program by [Chris Wanstrath][4].  It provides a lot of useful
functionality for interacting with GitHub and is a terrific complement
to `save-github-issues.pl`, in my opinion.



# Contributors

1. [Squeeks][1] `<squeek@cpan.org>`
2. [Mark Canlas][2]
3. [Stefany Dyulgerova][5]


# License

GNU General Public License Version 3



[1]: https://github.com/squeeks/
[2]: https://github.com/mcanlas/
[3]: http://defunkt.io/hub/
[4]: http://chriswanstrath.com/
[5]: https://github.com/Stefany93
