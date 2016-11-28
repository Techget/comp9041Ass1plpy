#!/usr/bin/perl -w
# put your test script here


sub changeToUpperCase{
	my $line = @_;

	$line =~ s/[a-z]/[A-Z]/;

	printf "%s\n",$line;
}

while($line = <>){
	chomp $line;
	print "line : $line\n";
	push @arr,$line;
}

while(@arr){
	my $temp = pop @arr;
	changeToUpperCase($temp);
}
