#!/usr/bin/perl

use warnings;
use strict;

my @machines = ();

while (<STDIN>) {
    if (/^\s*Supported machines are:/) {
	next;
    }

    s/^\s+//;
    my @machine = split(/\s+/);
    next if $machine[0] !~ m/^pc-(i440fx|q35)/;
    push @machines, $machine[0];
}

die "no QEMU machine types detected from STDIN input" if scalar (@machines) <= 0;

print join("\n", @machines) or die "$!\n";
