#!/usr/bin/perl -w
# put your demo script here

$line = <STDIN>;

if($line =~ /([a-zA-Z]+)([0-9]+)/){
	print "$2"."$1";
}

print "$0\n";

$line =~ s/a/A/g;

print "$line\n";

print "input a non-negative number:";

$num = <STDIN>;

if($num <= 0){
	print "wrong input\n";
	exit;
}

print "count numbers\n";

for($i=0;$i<$num;$i++){
	print "$i\n";
}

for($i=$num;$i>=0;$i--){
	print "$i\n";
}
