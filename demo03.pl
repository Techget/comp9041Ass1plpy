#!/usr/bin/perl -w
# put your demo script here


@arr = ('hello','world');

foreach my $i (@arr){
	print "$i\n";
}

@rra = reverse @arr;

foreach my $i (@rra){
	print "$i\n";
}


$j=0;

foreach my $i (@rra){
	$hash{$j}=$i;
	$j++;
}

foreach my $key (sort keys %hash){
	print "$hash{$key}\n";
}


