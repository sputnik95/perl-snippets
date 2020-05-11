#!/usr/bin/perl
use integer;
use strict;
use warnings;

new_brightness();

sub current_brightness {
    my $path = "/sys/class/backlight/acpi_video0/brightness";
    open my $fh, '<', $path or die $!;
    read $fh, my $brightness, -s $fh;
    chomp $brightness;
    return ($brightness, $path);
}

sub new_brightness {
    my $cur_brightness = (current_brightness())[0];
    my $path = (current_brightness())[1];
    my $entered = `echo $cur_brightness | dmenu -i -fn "Terminus:size=8" -nb "#111111" -nf "#8b8792" -sb "#111111" -sf "#cfcfcf" -p "New brightness level: "`; 
    $entered = ($entered eq "" ? $cur_brightness : int(($entered / 5.0)) * 5);
    open my $fh, '>', $path or die $!;
    print $fh $entered;
    close($fh);
}
