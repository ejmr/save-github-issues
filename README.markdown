# save-github-issues

This Perl program can automatically create a database of repository
issues for backup purposes, since Github currently does not provide
that functionality.



# Required Perl Modules

1. `common:sense`
2. `DBI`
3. `DBD::SQLite`
4. `LWP::UserAgent`
5. `JSON`

The program also requires [SQLite](http://sqlite.org).



# Usage

The program requires two arguments:

1. `--user`: This is the user whose owns the repositories you want
issues from.

2. `--repo`: This names the repository whose issues you want to save.
This option may appear multiple times.  *It is optional.*  If you do
not provide any `--repo` option then the program will download the
issues for every repository the user owns.

An example:

    $ ./save-github-issues.pl --user ejmr --repo php-mode --repo bbcode-mode
    Saving issues for user ejmr

    Saving issues for php-mode
    Saving issues for bbcode-mode

This creates a files called `issues.sqlite` in the current directory.
It is a database with the following columns:

1. `url`: The URL to the issue on Github.

2. `title`: The name of the issue.

3. `type`: A string indicating if the issue is ‘opened’ or ‘closed’,
and so on.

4. `json`: A long string of the raw JSON which Github returns.  This
is useful so you have a complete backup of all of the information
which the Github API provides.



# License

GNU General Public License Version 3
