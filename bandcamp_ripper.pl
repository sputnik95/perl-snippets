#!/usr/bin/env perl
use open ':std', ':encoding(UTF-8)';
use strict;
use utf8;
use warnings;
#use Data::Dumper;
use Encode qw(encode_utf8);
use JSON qw(decode_json);
use LWP::UserAgent;
use Mojo::DOM;
use MP3::Tag;

my $ua = LWP::UserAgent->new(timeout => 15);
$ua->show_progress(0); #change to 1 for debugging

main();

sub fill_tags {
    my $mp3 = MP3::Tag->new($_[0]) or die "No file downloaded!";
    my @info = @{$_[1]};
	$mp3->update_tags({
		artist => $info[0],
		title => $info[1],
		album => $info[2],
		year => $info[4],
	});
    $mp3->close();
}

sub get_track_page {
    my $response = $ua->get($_[0]);
    $response->is_success ? my $html = $response->decoded_content : die "No response!";
    my $dom = Mojo::DOM->new($html);
    return $dom;
}

sub get_track_info {
    my $dom = get_track_page($_[0]);
    my $track_title = $dom->at("h2.trackTitle")->text;
    $track_title =~ s/^\s+|\s+$//g;
    my $track_album = $dom->at("span.fromAlbum")->text;
    my $track_year = $dom->at("div.tralbumData.tralbum-credits")->text;
    my @track_year = $track_year =~ m/(\d{4})/;
    $track_year = $track_year[0];
    my $track_artist = $dom->at("span[itemprop=byArtist]")->at("a")->text;
    my @trackinfo = grep /trackinfo: /mi, split /\n/, $dom;
    my $track_link;
    if (@trackinfo) {
        my $trackinfo = $trackinfo[0];
        $trackinfo =~ s/^\s+trackinfo: //;
        $trackinfo =~ s/,$//;
        $trackinfo = decode_json(encode_utf8($trackinfo));
        #print Dumper $trackinfo;
        for my $entry ( @{$trackinfo} ) {
            $track_link = $entry->{file}->{'mp3-128'};
        }
    }
    return ($track_artist, $track_title, $track_album, $track_link, $track_year);
}

sub get_track {
    my @info = get_track_info($_[0]);
    my $filename = $info[0] . " - " . $info[1] . ".mp3";
    my $dir = $info[4] . " - " . $info[0] . " - " . $info[2];
    my $path = $dir . "/" . $filename;
    mkdir($dir);
    $ua->mirror($info[3], $path);
    fill_tags($path, \@info);
    print "Saved to \"$path\"\n";
}

sub get_album_page {
    my $response = $ua->get($_[0]);
    $response->is_success ? my $html = $response->decoded_content : die "No response!";
    my $dom = Mojo::DOM->new($html);
    my $root = $dom->at("span[itemprop=byArtist]")->at("a")->attr("href");
    my @track_pages;
    for my $e ($dom->find('div[class=title]')->each) {
        my $url = $root . $e->at("a[itemprop=url]")->attr("href");
        push(@track_pages, $url);
    }
    return @track_pages;
}

sub get_album {
    my @track_pages = get_album_page($_[0]);
    my $length = @track_pages;
    print "Found " . $length . " tracks. Downloading...\n";
    foreach(@track_pages) {
        get_track($_);
    }
    print "Done\n";
}

sub main {
    my $url = (exists($ARGV[0]) ? $ARGV[0] : "");
    $url eq "" ? print "\nThis script will download mp3s into album's subdirectory and populate each file with id3v2 tags.\nPass bandcamp album link as a parameter in order to start the download:\n\n\$ ./script.pl https://80beats.bandcamp.com/album/the-bodega-tape\n\$ perl script.pl https://80beats.bandcamp.com/album/the-bodega-tape\n\nYou may also want to copy the script somewhere in your \$PATH to be able to execute it from any directory.\n\n" : get_album($url);
}

