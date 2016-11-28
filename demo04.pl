#!/usr/bin/perl -w
# put your demo script here

sub outPut{
	my $line = @_;
	printf "%s\n",$line;
}

@arr = ("I","love","peace","hello","world");

while(@arr){
	my $temp = shift @arr;
	$hashTable{$temp}=$temp;
}

foreach my $i (sort keys %hashTable){
	$concat .= " ";
	$concat .= $i;
	printf "%s\n",$hashTable{$i};
}

$concat =~ s/a/A/g;

printf "concatenation:%s\n",$concat;


$i=0
while($line = <>){
	chomp $line;
	push @lines,$line;
	$hash{$i}=$line;
	$i++;
}

outPut($lines[0])



