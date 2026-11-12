package Locale::Maketext::Simple;

use strict;
use warnings;

# Minimal stub of Locale::Maketext::Simple for perl distributions that do not ship it
# (e.g. the stripped down perl bundled with Git for Windows). Only the C<loc> function
# used by Params::Check/IPC::Cmd for localized diagnostic messages is provided.

sub import {
    my ($class, @args) = @_;
    my $caller = caller;
    no strict 'refs';
    *{"${caller}::loc"} = \&loc unless defined &{"${caller}::loc"};
}

sub loc {
    my ($message, @arguments) = @_;
    return $message unless @arguments;
    $message =~ s/%(\d+)/defined $arguments[$1 - 1] ? $arguments[$1 - 1] : ''/ge;
    return $message;
}

1;
