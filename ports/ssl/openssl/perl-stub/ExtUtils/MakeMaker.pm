package ExtUtils::MakeMaker;

use strict;
use warnings;

# Minimal stub of ExtUtils::MakeMaker for perl distributions that do not ship it
# (e.g. the stripped down perl bundled with Git for Windows). Only the
# C<maybe_command> function used by IPC::Cmd to locate executables is provided.

sub maybe_command {
    my ($class, $file) = @_;
    return $file if defined $file && -f $file && -x _;
    return;
}

# IPC::Cmd calls MM->maybe_command(), MM is an alias package of ExtUtils::MakeMaker
package MM;

our @ISA = ('ExtUtils::MakeMaker');

1;
