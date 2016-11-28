#!/usr/bin/perl -w
# put your test script here

while(my $fred = <>) {
    chomp $fred;
    $concate .= $fred;
    print "$fred\n";
}

$tr = $concate;
$tr =~ tr/aeiou/12345/;

$concate .= " ".$tr;

print "concatenation and transliterate : $concate\n";
