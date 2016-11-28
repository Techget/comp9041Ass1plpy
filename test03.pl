#!/usr/bin/perl -w
# put your test script here

print "input a positive number:";
$num = <STDIN>;

if($num <= 0){
	print "wrong input\n";
	exit;
}

for($i=0;$i<$num;$i++){
	print "$i\n";
}

for($i=$num;$i>=0;$i--){
	print "$i\n";
}


##check if it is greate than 100;

$hundred=100;
$fifty=50;

if($num - 100 >=0){
	print "greater than 100\n";
	print "num substract hundred : $num - $hundred\n";
}elsif($num -$fifty >=0  ){
	print "num substract fifty: $num - $fifty\n";
}else{
	print "whatever\n";
}
