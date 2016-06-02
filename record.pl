#!/usr/bin/perl
##############################################
### DVR RECORD SCRIPT FOR SMOOTHSTREAMS.TV ###
###   Contact me at <aTheN99@gmail.com>    ###
##############################################
$|++;
use strict;
use Proc::Background qw(timeout_system);

my $username = "replace_me";  ### SMOOTHSTREAMS LOGIN
my $password = "replace_me";  ### SMOOTHSTREAMS PASSWORD
my $PATH = "/mnt/usb/DVR";    ### STORE SAVED FILES PATH

# CRONTAB Example:
# 59 22 *   *   */1   /home/ctaylor/source/dvr/record.pl 1 31 "RobotChicken"

my $channel = $ARGV[0];
my $minutes = $ARGV[1];     ### APPROX 15MB PER MINUTE, 900MB PER HOUR
my $show = $ARGV[2];

if (!$channel || !$minutes) {
    die("Usage: $0 [channel] [minutes]\n");
}

my $TIME = $minutes * 60;

my $TIMESTAMP = `date "+%Y_%m_%d__%H_%M_%S"`; chop($TIMESTAMP);
my $FILENAME = "$PATH/";
if ($show) { $FILENAME.= "$show" . "_"; }
$FILENAME.= "ch$channel-$TIMESTAMP.mp4";

my $HASH_URL = "http://smoothstreams.tv/schedule/admin/dash_new/hash_api.php?site=viewstvn&username=$username&password=$password";

my $hash = `/usr/bin/curl -s "$HASH_URL"`;
if (index($hash, "\"hash\":\"") == -1) {
    die("Unable to authenticate.\n");
}
$hash = strstr($hash, "{\"hash\"", 1);
$hash = strstr($hash, ":", 2);
$hash = strrstr($hash, "\"");

if ($hash) {
    my $RTMP_URL = "rtmp://dNAw.SmoothStreams.tv:3615/viewstvn?user_agent=Smoothstreams.tv_0.7.1b%20%28Kodi%2016.1%20Git%3A2016-04-25-b08ce71-dirty%3B%20Linux%20armv7l%29%20RPi&wmsAuthSign=$hash/ch". sprintf("%02d", $channel) . "q1.stream";
    my $cmd = "/usr/bin/rtmpdump -q -r \"$RTMP_URL\" -o $FILENAME";

    system("clear");
    print "Recording CHANNEL #$channel for $minutes minute(s)...\n\n";

    print "Output: $FILENAME\n";
    print "URL: $RTMP_URL\n";
    print "Command: $cmd\n\n";
    timeout_system($TIME, $cmd);

    my $cmd = `/usr/bin/pkill rtmpdump`;
    print "done.\n";
}

sub strstr($$$) {
    my ($haystack, $needle, $offset) = @_; if (!$offset) { $offset = 0; }
    if ((my $pos = index($haystack, $needle)) > -1) { $haystack = substr($haystack, $pos+$offset); } return $haystack; 
}

sub strrstr($$) {
    my ($haystack, $needle) = @_;
    if ((my $pos = index($haystack, $needle)) > -1) { $haystack = substr($haystack, 0, $pos); } return $haystack; 
}
