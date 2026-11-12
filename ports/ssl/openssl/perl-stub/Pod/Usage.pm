package Pod::Usage;

use strict;
use warnings;

require Exporter;

our @ISA    = ('Exporter');
our @EXPORT = ('pod2usage');

# Minimal stub of Pod::Usage for perl distributions that do not ship it
# (e.g. the stripped down perl bundled with Git for Windows). Only the C<pod2usage>
# function used by openssl's configdata.pm is provided.

sub pod2usage {
    my (%arguments) = @_;
    my $message = $arguments{-message};
    print STDERR $message if defined $message && length $message;
    exit(defined $arguments{-exitval} ? $arguments{-exitval} : 0);
}

1;
