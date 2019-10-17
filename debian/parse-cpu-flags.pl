#!/usr/bin/perl

use warnings;
use strict;

my @flags = ();
my $got_flags_section;

while (<STDIN>) {
    if (/^\s*Recognized CPUID flags:/) {
	$got_flags_section = 1;
	next;
    }
    next if !$got_flags_section;

    s/^\s+//;

    push @flags, split(/\s+/);
}

die "no QEMU/KVM CPU flags detected from STDIN input" if scalar (@flags) <= 0;

print join("\n", @flags) or die "$!\n";
