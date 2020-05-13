#!/usr/bin/env perl
use strict;
use warnings;
use Time::HiRes qw(gettimeofday);

main();

sub transliterate {
    my $txt = $_[0];
    # This won't be pretty...
    $txt =~ s/А/A/g;    $txt =~ s/а/a/g;
    $txt =~ s/Б/B/g;    $txt =~ s/б/b/g;
    $txt =~ s/В/V/g;    $txt =~ s/в/v/g;
    $txt =~ s/Г/G/g;    $txt =~ s/г/g/g;
    $txt =~ s/Д/D/g;    $txt =~ s/д/d/g;
    $txt =~ s/Е/E/g;    $txt =~ s/е/e/g;
    $txt =~ s/Ё/E/g;    $txt =~ s/ё/e/g;
    $txt =~ s/Ж/ZH/g;   $txt =~ s/ж/zh/g;
    $txt =~ s/З/Z/g;    $txt =~ s/з/z/g;
    $txt =~ s/И/I/g;    $txt =~ s/и/i/g;
    $txt =~ s/Й/I/g;    $txt =~ s/й/i/g;
    $txt =~ s/К/K/g;    $txt =~ s/к/k/g;
    $txt =~ s/Л/L/g;    $txt =~ s/л/l/g;
    $txt =~ s/М/M/g;    $txt =~ s/м/m/g;
    $txt =~ s/Н/N/g;    $txt =~ s/н/n/g;
    $txt =~ s/О/O/g;    $txt =~ s/о/o/g;
    $txt =~ s/П/P/g;    $txt =~ s/п/p/g;
    $txt =~ s/Р/R/g;    $txt =~ s/р/r/g;
    $txt =~ s/С/S/g;    $txt =~ s/с/s/g;
    $txt =~ s/Т/T/g;    $txt =~ s/т/t/g;
    $txt =~ s/У/U/g;    $txt =~ s/у/u/g;
    $txt =~ s/Ф/F/g;    $txt =~ s/ф/f/g;
    $txt =~ s/Х/KH/g;   $txt =~ s/х/kh/g;
    $txt =~ s/Ц/TS/g;   $txt =~ s/ц/ts/g;
    $txt =~ s/Ч/CH/g;   $txt =~ s/ч/ch/g;
    $txt =~ s/Ш/SH/g;   $txt =~ s/ш/sh/g;
    $txt =~ s/Щ/SCH/g;  $txt =~ s/щ/sch/g;
    $txt =~ s/Ь/'/g;    $txt =~ s/ь//g;
    $txt =~ s/Ы/Y/g;    $txt =~ s/ы/y/g;
    $txt =~ s/Ъ/''/g;   $txt =~ s/ъ//g;
    $txt =~ s/Э/E/g;    $txt =~ s/э/e/g;
    $txt =~ s/Ю/YU/g;   $txt =~ s/ю/yu/g;
    $txt =~ s/Я/YA/g;   $txt =~ s/я/ya/g;
    $txt =~ s/ /_/g;
    return $txt;
}

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
    my $arg = $_[0];
    my %filenames = get_filenames();
    foreach my $old_file (keys %filenames) {
        my $new_file;
        my $old_file_ext = $filenames{$old_file};
        if ($arg eq "-e") { $new_file = gen_timestamp() . $old_file_ext; }
        elsif ($arg eq "-t") { $new_file = transliterate($old_file); }
        rename $old_file, $new_file;
        print sprintf "%-15s -> %s\n", $old_file, $new_file;
    }
}

sub main {
    my $arg = (exists($ARGV[0]) ? $ARGV[0] : $0);
    ( $arg ne "-e" && $arg ne "-t" ) ? print "\nThis script changes all filenames (not subdirectory names!) in a current directory.
Please be cautious with it!
Pass either of parameters to start:

-e
    change all filenames to epoch time:
    \$ ./script.pl -e
    image.jpg       -> 1589400553628122.jpg

-t
    transliterate filenames from cyrillic:
    \$ ./script -t
    пример файла.doc -> primer_faila.doc

You may also want to copy the script somewhere in your \$PATH to be able to execute it from any directory.\n\n" : rename_files($arg);
}
