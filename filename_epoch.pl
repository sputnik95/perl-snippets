#!/usr/bin/env perl
use strict;
use warnings;
use Time::HiRes qw(gettimeofday);

main();

sub gen_timestamp {
    my $timestamp = int (gettimeofday * 1000000);
    return $timestamp;
}

sub get_files {
    opendir(DIR, ".") or die $!;
    my @files = grep { !/^\.+$/ } readdir(DIR);
    close(DIR);
    return @files;
}

sub get_filenames {
    my %filenames;
    foreach my $file_old (get_files()) {
        if (-f $file_old) { #check if file not dir
            my $script_name = (index($0, "./") == 0 ? substr($0, 2) : $0);
            if ($file_old !~ /^$script_name$|^.$|^..$/) {
                my ($ext) = $file_old =~ /(\.[^.]+)$/;
                $filenames{$file_old} = $ext;
            }
        }
    }
    return %filenames;
}

sub rename_files {
    my %filenames = get_filenames();
    foreach my $old_file (keys %filenames) {
        my $old_file_ext = $filenames{$old_file};
        my $new_file = gen_timestamp() . $old_file_ext;
        rename $old_file, $new_file;
        print $old_file . " -> " . $new_file . "\n";
    }
}

sub main {
    my $arg = (exists($ARGV[0]) ? $ARGV[0] : $0);
    $arg ne "-y" ? print "This script renames all files in current directory to unix epoch time (in milliseconds).\nPass \"-y\" parameter to start it:\n./script.pl -y\n" : rename_files();
}
