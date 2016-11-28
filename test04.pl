#!/usr/bin/perl -w
# put your test script here


@arr = ("h","e","l","l","o");

@arr2 = ("w","o","r","l","d");


@arrT = reverse @arr;
while(@arrT){
	
	$charac = shift @arrT;

	unshift @arr2,$charac;
	
}

for($i =0; $i< $#arr2 ; i++){
	print "$arr2[$i]\n";
}

