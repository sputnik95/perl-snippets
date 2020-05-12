Small collection of simple scripts I wrote using perl 5.
#### bandcamp_ripper.pl
Used to download albums from bandcamp in mp3 128kbps (or in another format songs are published in on album's webpage). Requires album's url passed as a parameter to run.  
Run the following to install dependencies:
```sh
7:48PM ~$ cpan -i App::cpanminus && cpanm LWP::UserAgent Mojo::DOM MP3::Tag
```
Script output example:
```sh
7:48PM ~/Downloads$ bandcamp_ripper https://pinkshinyultrablast.bandcamp.com/album/grandfeathered
Found 2 tracks. Downloading...
Saved to "2015 - Pinkshinyultrablast - Grandfeathered/Pinkshinyultrablast - Kiddy pool dreams.mp3"
Saved to "2015 - Pinkshinyultrablast - Grandfeathered/Pinkshinyultrablast - The Cherry Pit.mp3"
Done
```
#### brightness.pl
Dmenu-powered simple screen brightness changer. Could be useful for minimal installs.
Takes in a number of brightness percentage (without a percent sign) and puts it in `/sys/class/backlight/acpi_video0/brightness`, thus effectively changing screen brightness.
To override `Permission denied` error add perl binary path to sudoers file:
```
ALL ALL=NOPASSWD: /usr/bin/apt,/usr/bin/perl
```
And invoke the script with a prepending sudo:
```sh
sudo dmenu_brightness
```
#### filename_epoch.pl
Script used to rename each file in current directory to unix time (or epoch time) in microseconds.
Output example: 
```sh
 8:03PM ~/Downloads$ filename_epoch -y
-1.jpg -> 1589303022049845.jpg
0A0A44E8-BE23-443A-A26A-FC5D75525347.jpg -> 1589303022049920.jpg
++++++Nature of Man.png -> 1589303022049942.png
191ZOIN-sbI.jpg -> 1589303022049958.jpg
 8:03PM ~/Downloads$ ls -1                                                    
1589303022049845.jpg
1589303022049920.jpg
1589303022049942.png
1589303022049958.jpg
```
#### network_traffic.pl
This script outputs current traffic usage per second. Could be used as a widget on some kind of bar (like dzenbar or lemonbar) that continously loops the script and displays it's output. Needs a device name passed as a parameter.  
Output example:
```sh
 8:09PM ~$ network_traffic wlan0
 ↓ 43 KB/s ↑ 4 KB/s
 ```
Find your network device's name with `ip link` command.
