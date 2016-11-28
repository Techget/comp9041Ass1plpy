#!/usr/bin/perl -w
# put your test script here

#
## take in a filename , opens the file, and prints the contents , incorrect command line input,
## gives out the warning message

if($#ARGV == 0) {
	print "You must specify exactly one argument.\n";
	exit 4;
}

print "$0\n";

@files = @ARGV;


foreach $file (@files){

	# Open the file.
	open INFILE, "<$file";

	while(my $l = <INFILE>) {
		print $l;
	}

	close INFILE;
}
