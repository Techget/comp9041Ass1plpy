#!/usr/bin/perl -w
# put your demo script here

$line_count=0;

while ($line = <STDIN>) {
	chomp $line;
	$concat_line .= $line;
	$line_count++;
	print "$line\n";
}

print "concat_line : $concat_line\n";

print "$line_count lines\n";

if($concat_line =~ /hello/){
	for($i=0;$i < 5;$i++){
		print "match hello\n";
	}
}

