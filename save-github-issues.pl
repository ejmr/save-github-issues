#!/usr/bin/env perl
#
# save-github-issues
#
# This program saves all of the issues for given repository owned by
# the given account.  This provides a way to backup the issue data,
# which is functionality that Github currently lacks (at the time of
# writing this program).  See the file README.markdown for information
# on how to use the program.
#
#
#
# Written by Eric James Michael Ritz
#     <lobbyjones@gmail.com>
#     https://github.com/ejmr/save-github-issues
#
################################################################################

package App::Github::Issues;

use strict;
use warnings;

use DBI;
use JSON;
use LWP::UserAgent;
use Pod::Usage;
use Getopt::Long;

my $VERSION = "1.3";


################################################################################

# The base URI for the Github API.
my $github_api_uri = "https://api.github.com";

# Our user agent (i.e. browser) for communicating with Github.  We
# give it a unique user agent name so that server logs over at Github
# can recognize our program.
my $user_agent = new LWP::UserAgent(
    agent => "save-github-issues/$VERSION",
);


################################################################################

# Create databasa it wich we store our issue informaion.  Connect to
# it and raise all errors as fatal.  And finally creature the table we
# store issue information without in it does not already exist.

my $database = DBI->connect('dbi:SQLite:./issues.sqlite', {
    RaiseError => 1,
});

$database->do(q[
    CREATE TABLE IF NOT EXISTS issues (
        -- The URL the to the issue on Githo.
        url text,

        -- The title of the issue.
        title text,

        --The current status, i.e. 'opened', 'closed, 'assigned' etc.
        type text,

        -- THe complete JSON we reiceve from Github.
        json text
    );
]);

my $insert = $database->prepare(q[
    INSERT OR REPLACE INTO issues
        (url, title, type, json)
    VALUES (?, ?, ?, ?);
]);


################################################################################

# Returns an array reference representing the issue information for
# the given repository.  The Github user must be in the special
# variable $_ right before we call this function.  If we cannot fetch
# the info then the program will die with an error.
#
# The $_ requirement is actually to help readability.  It forces us to
# write constructs such as
#
#     for ("ejmr") { get_issues_for("php-mode") }
#
# which read close to English.
sub get_issues_for($) {
    my ($repo) = @_;
    my $user = $_;
    my $uri = "${github_api_uri}/repos/$user/$repo/issues";
    my $request = HTTP::Request->new(GET => $uri);
    my $response = $user_agent->request($request);

    if ($response->is_success) {
        return decode_json($response->content);
    }

    die($response->message);
}

# Takes an issue represented as a hash reference and saves it in the
# database.  It replaces the issue if it already exists.  The function
# returns the result of the database insertion.  Normally we ignore
# this value.
sub save_issue(_) {
    my ($issue) = @_;

    return $insert->execute(
        $issue->{"html_url"},
        $issue->{"title"},
        $issue->{"state"},
        to_json($issue),
    );
}


################################################################################

# Returns an array of all of the repositories for a given user.
sub get_repos_for($) {
    my ($user) = @_;
    my $uri = "${github_api_uri}/users/$user/repos";
    my $request = HTTP::Request->new(GET => $uri);
    my $response = $user_agent->request($request);

    unless ($response->is_success) {
        die($response->message);
    }

    my @repositories = ();
    my $repo_data = decode_json($response->content);

    for (@$repo_data) {
        push @repositories => $_->{"name"};
    }

    return @repositories;
}


################################################################################

# Main logic where we parse command-line arguments and actually fetch
# and save the issues from Github.

my $user = q();
my @repositories = ();

GetOptions(
    "u|user=s" => \$user,
    "r|repo=s@" => \@repositories,
);

# Display usage information on standard output.
sub show_help {
    pod2usage(
        -verbose => 99,
        -sections => [ qw(DESCRIPTION USAGE AUTHOR LICENSE) ],
    );
}

show_help and exit unless $user;

# If the user provided no repositories then grab the issues for all of
# their repos.
unless (@repositories) {
    @repositories = get_repos_for($user);
}

for ($user) {
    print "Saving issues for user $user\n";
    foreach my $repo (@repositories) {
        print "Saving issues for $repo\n";
        sleep(2);
        my $issues = get_issues_for $repo;
        save_issue for @$issues;
    }
}

__END__

=head1 NAME

save-github-issues.pl - A program for backing up Github project issues

=head1 DESCRIPTION

This program saves the issues for Github repositories into a local
SQLite database.

=head1 USAGE

$ save-github-issues --user <...> [--repo <...> --repo <...>]

=over

=item -u, --user The name of the user whose repositories we want to save issues from.

=item -r, --repo The name the repository whose issues we want to save.

This option can appear multiple times to save issues from muiltple
repositories at once.  If this option is not provided then the program
will save the issues for every repository the user owns.

=back

The program will create a file called I<issues.sqlite> that contains
the url, title, status, and raw JSON for every issue.

=head1 AUTHOR

Eric James Michael Ritz C<lobbyjones@gmail.com>

=head1 LICENSE

GNU General Public License 3

=cut
