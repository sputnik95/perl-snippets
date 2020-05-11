#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use LWP::Simple qw(get getstore);
use JSON qw(decode_json);
use Mojo::DOM;
use MP3::Tag;
use utf8;
use open ':std', ':encoding(UTF-8)';

get_album();

sub get_album {
    print "This script will download mp3's into current directory and fill in id3 tags.\n";
    print "Enter album url: ";
    my $url = <>;
    my @track_pages = get_album_page($url);
    foreach(@track_pages) {
        get_track($_);
    }
    print "Done\n";
}

sub get_album_page {
    my $html = get $_[0];
    my $dom = Mojo::DOM->new($html);
    my $root = $dom->at("span[itemprop=byArtist]")->at("a")->attr("href");
    my @track_pages;
    for my $e ($dom->find('div[class=title]')->each) {
        my $url = $root . $e->at("a[itemprop=url]")->attr("href");
        push(@track_pages, $url);
    }
    return @track_pages;
}

sub fill_tags {
    my $mp3 = MP3::Tag->new($_[0]) or die "No file downloaded!";
    my @info = $_[1];
    $mp3->artist_set($info[0]);
    $mp3->title_set($info[1]);
    $mp3->album_set($info[2]);
    $mp3->update_tags();
}

sub get_track {
    my @info = get_track_info($_[0]);
    my $filename = $info[0] . " - " . $info[1] . ".mp3";
    getstore($info[3], $filename);
    fill_tags($filename, @info);
    print "Saved to $filename\n";
}

sub get_track_page {
    my $html = get $_[0];
    my $dom = Mojo::DOM->new($html);
    return $dom;
}

sub get_track_info {
    my $dom = get_track_page($_[0]);
    my $track_title = $dom->at("h2.trackTitle")->text;
    $track_title =~ s/^\s+|\s+$//g;
    my $track_album = $dom->at("span.fromAlbum")->text;
    my $track_artist = $dom->at("span[itemprop=byArtist]")->at("a")->text;
    my @trackinfo = grep /trackinfo: /mi, split /\n/, $dom;
    my $track_link;
    if (@trackinfo) {
        my $trackinfo = $trackinfo[0];
        $trackinfo =~ s/^\s+trackinfo: //;
        $trackinfo =~ s/,$//;
        $trackinfo = decode_json($trackinfo);
        #print Dumper $trackinfo;
        for my $entry ( @{$trackinfo} ) {
            $track_link = $entry->{file}->{'mp3-128'};
        }
    }
    return ($track_artist, $track_title, $track_album, $track_link);
}

