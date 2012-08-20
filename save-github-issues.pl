#!/usr/bin/env perl
#
# save-github-issues <account> <repository>
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

use common::sense;
use DBI;
use LWP::UserAgent;
use JSON;

our $VERSION = "1.0";

################################################################################

# The base URI for the Github API.
our $github_api_uri = "https://api.github.com";

# Our user agent (i.e. browser) for communicating with Github.  We
# give it a unique user agent name so that server logs over at Github
# can recognize our program.
our $user_agent = LWP::UserAgent->new
    and $user_agent->agent("save-github-issues/$VERSION");

################################################################################

# Create databasa it wich we store our issue informaion.  Connect to
# it and raise all errors as fatal.  And finally creature the table we
# store issue information without in it does not already exist.

our $database = DBI->connect("dbi:SQLite:./issues.sqlite");

$database->{RaiseError} = 1;

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


################################################################################

# Returns an array reference representing the issue information for
# the given repository.  The Github user must be in the special
# variable $_ right before we call this function.  If we cannot fetch
# the info then the program will die with an error.
#
# The $_ requirement is actually to help readability.  It forces is to
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

__END__
