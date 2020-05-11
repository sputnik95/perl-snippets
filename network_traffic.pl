#!/usr/bin/perl
use Fcntl;
use strict;
use warnings;

!@ARGV ? print "usage: ./net.pl devname\nexample: ./net.pl wlp3s0\n" : form_output();

sub get_net_dev {
    my $path = "/proc/net/dev";
    sysopen(DATA, $path, O_RDONLY) or die $!;
    my $netdev = do { local $/; <DATA> };
    close(DATA);
    return $netdev;
}

sub parse_net_dev {
    my $netdev = (get_net_dev())[0];
    my @match = grep /@ARGV/mi, split /\n/, $netdev;
    if (@match) {
        my @net_values = split /\s+/, $match[0];
        my $down_speed = $net_values[1];
        my $up_speed = $net_values[9];
        return ($down_speed, $up_speed);
    }
}

sub form_output {
    my @speeds_1 = parse_net_dev();
    sleep(1);
    my @speeds_2 = parse_net_dev();
    my $inspeed  = int(($speeds_2[0] - $speeds_1[0])/1024);
    my $outspeed = int(($speeds_2[1] - $speeds_1[1])/1024);
    print " ↓ $inspeed KB/s ↑ $outspeed KB/s \n";
}
