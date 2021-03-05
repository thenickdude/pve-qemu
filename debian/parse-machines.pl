#!/usr/bin/perl

use warnings;
use strict;

use JSON;

my $machines = [];

while (<STDIN>) {
    if (/^\s*Supported machines are:/) {
	next;
    }

    s/^\s+//;
    my @machine = split(/\s+/);
    next if $machine[0] !~ m/^pc-(i440fx|q35)-(.+)$/;
    push @$machines, {
        'id' => $machine[0],
        'type' => $1,
        'version' => $2,
    };
}

die "no QEMU machine types detected from STDIN input" if scalar (@$machines) <= 0;

print to_json($machines, { utf8 => 1 }) or die "$!\n";
