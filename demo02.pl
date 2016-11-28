#!/usr/bin/perl -w
# put your demo script here

# Echo input to output, letting STDIN default.


# Read in texts, concate them by a space and print.
# Stops when it reaches the indicated count, the
# end of file, or the line STOP!

# Read the number.
print "How many lines you want to read in? ";
my $num = <STDIN>;
print "You entered $num\n";
if($num <0){
	exit;
}
# Read in the texts.

while(my $line = <STDIN>) {
	chomp $line;
	if($line eq "STOP!") { 
		last;
	}
	$temp = $sep.$line;
	$i = $i.$temp;

	$num--;

	if($num == 0) { 
		last;
	}

	$sep = " ";
}

# Print what we got.
print "$i\n";


