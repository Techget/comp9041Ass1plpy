#!/usr/bin/perl -w

# written by z5089812@cse.unsw.edu.au September 2016
# Xuan Tong
# Replace this comment with your own header comment

#####assume that the perl program is well indented
#####remain the indent 
#####print "$line", implies use the indent


#store all the python program into an array
#@pythonArray;


sub printProcess{
	my ($line,$indent,$content) = @_;
	# Python's print adds a new-line character by default
	# so we need to delete it from the Perl print statement
	#$indent = $1;
	#$content = $2;

	if($line =~ /printf/){
		##means it could be %, it carries and % format
		##then follow that
		#print "$content\n";		
		my $suf = $content;
	 	$suf =~ s/\".*?\"\s*,\s*(.*)$/$1/;
		#print "\$suf:$suf\n";
		my @suffix = split(",",$suf); 

		#print "\$content:$content\n";
		#print "\@suffix:@suffix\n";
		$content =~ s/\Q$suf\E//;
		$content =~ s/\\n",//;
		$content =~ s/\"//g;
		
		#print "\$content:$content\n"; 

		my $formatString = "";
		my $i=0;

		if ($content =~ /(?:\w+\[\w+\])|(?:\$\w+[^\[\]]?)|(?:\%[a-zA-Z0-9]*)/){
			my @matches=($content=~/(?:\w+\[\w+\])|(?:\$\w+[^\[\]]?)|(?:\%[a-zA-Z0-9]*)/g);
			#print "\@matches:@matches\n";
			while(@matches){
				my $tempExpression = shift @matches;
				if($tempExpression =~ /\%[a-z-A-Z0-9]*/){
					my $value = shift @suffix;
					$formatString = "$formatString,$value";
				}else{
					$content =~ s/\Q$tempExpression\E/\%s/;
					#$formatString = join($formatString,$tempExpression);
					$formatString = "$formatString,$tempExpression";
					#$i++;
				}
			}
			#$formatFlag=1;
		}
	
		$formatString =~ s/,//;
		$formatString =~ s/\$//g;
		#print "$indent"."print(\"$content\"\%\($formatString\))\n";

		push @pythonArray,"$indent"."print(\"$content\"\%\($formatString\))\n";

	}else{
		$content =~ s/\"//g;
		#in order to remove ", \n" , if not match remove \n
		$content =~ s/, \\n$//;
		$content =~ s/\\n$//;

		# if contains expression in the print, need to evaluate it
		# get rid of a special case where a single $ in the output with this if statement, and 
		# could get all the expressions
		my $formatString = "";
		my $i=0;
		my $formatFlag=0;

		#print "$content\n";
		# if($content =~ /sys.argv\[\$*\w+\]/){
		# 	print "here"
		# }
		##deal with hash[index] and sys.argv[num] 
		if ($content =~ /\w+\[\w+\]/ or $content =~ /sys.argv\[\$*\w+\]/){
			my @matches = ( $content =~ /(?:\w+\[\w+\])|(?:sys.argv\[\$*\w+\])/g);
			while(@matches){
				my $tempExpression = shift @matches;
				$content =~ s/\Q$tempExpression\E/\{\Q$i\E\}/;
				$tempExpression =~ s/\$//;
				#$formatString = join($formatString,$tempExpression);
				$formatString = "$formatString,$tempExpression";
				$i++;
			}
			$formatFlag=1;
		}
	
		##deal with expression
		if ( $content =~ /\$\w+[^\[\]]?/){
			my @matches = ( $content =~ /(?:\$[\w]+\s*[\+|\-|\*|\/|\%|\*\*]\s*)*\$[\w]+/g);
			#print "\@matches:@matches\n";
			#my $i=0;
			#my $formatString = "";
			while(@matches){
				my $tempExpression = shift @matches;
				$content=~s/\Q$tempExpression\E/\{\Q$i\E\}/;
				#$formatString = join($formatString,$tempExpression);
				$formatString = "$formatString,$tempExpression";
				$i++;
			}
			#remove the first , in the $formatString
			$formatFlag=1;
		
		}

		if($content =~ /\@\w+/){
			my @matches = ($content =~/\@\w+/g);
			while(@matches){
				my $tempExpression = shift @matches;
				$content =~ s/\Q$tempExpression\E/\{\Q$i\E\}/;
				$tempExpression =~ s/\@//;
				$formatString = "$formatString,\"\".join($tempExpression)";
				$formatFlag=1;
			}
		}

		$formatString =~ s/,//;
		$formatString =~ s/\$//g;

		if($formatFlag){
			#print "$indent"."print(\'$content\'\.format\($formatString\))\n";
			push @pythonArray,"$indent"."print(\'$content\'\.format\($formatString\))\n";
		}elsif($content=~ /\$\w+\[\$\w+\]/){
			#array elements
			$content =~ s/\$//g;
			#print $indent."print($content)\n";
			push @pythonArray, $indent."print($content)\n";
		}elsif($content =~ /[^\.]+\.[^\.]+/){
			#specific for sys.argv
			#for examples/4/echon.1.pl , output a array elements in a print clause is not completed, by lucky coincidence, 
			#this question asks for sys.argv, so if meet the array elements, should try to solve that.
			$content =~ s/\$//g;
			#print "$indent"."print($content)\n";
			push @pythonArray, "$indent"."print($content)\n";
		}elsif($content =~ /\w+\[.*\]/ or $content =~ /\w+\(.*\)/){
			#print "$indent"."print($content)\n" ;
			push @pythonArray, "$indent"."print($content)\n" ;
		}else{
			#print "$indent"."print(\"$content\")\n" ;
			push @pythonArray, "$indent"."print(\"$content\")\n" ;
		}
	}
}

#re.sub(pattern, repl, string, count=0, flags=0)
sub equalTildeProcess{
	my $numParameters = @_ ;
	#print "\$numParameters:$numParameters\n";
	my ($indent,$varName,$prefix,$pattern,$repl) = @_;
	$pattern = "\'$pattern\'";
	if(! $repl){
		$repl="\'\'";
	}
	if($numParameters == 5){
		if($prefix eq 's'){
			#print $indent."$varName=re.sub($pattern,$repl,$varName,count=1)\n";
			push @pythonArray, $indent."$varName=re.sub(r$pattern,r\'$repl\',$varName,count=1)\n";
		}elsif($prefix eq 'tr'){
			#print $indent."$varName.translate(maketrans($pattern, $repl))";
			$pattern =~ s/\'//g;
			push @pythonArray,$indent."$varName.translate(str.maketrans(\"$pattern\", \"$repl\"))\n";
		}
	}elsif($numParameters == 6){
		my $suffix = $_[5];
		if($prefix eq 's'){
			if($suffix eq 'g'){
				#print $indent."$varName=re.sub($pattern,$repl,$varName)\n";
				if($repl eq "\'\'"){
					push @pythonArray, $indent."$varName=re.sub($pattern,$repl,$varName)\n";
				}else{
					push @pythonArray, $indent."$varName=re.sub($pattern,\"$repl\",$varName)\n";
				}
			}
		}
	}else{
		print "equalTildaProcess wrong input\n";
	}
}

#go through pythonArray to see which module need to be imported
sub importStatement{
	my $pyArrayRef= $_[0];
	my $importAddIndex=0;

	for my $arg (@$pyArrayRef){
		if ($arg =~ /^\s*\#/){
			$importAddIndex++;
			next;
		}else{
			last;
		}
	}

	my %importHash;	
	for my $arg (@$pyArrayRef){
		if ($arg =~ /re\./){
			$importHash{re}=1;	
		}
		if ($arg =~ /sys\./){
			$importHash{sys}=1;
		}
		if ($arg =~ /fileinput\./){
			$importHash{fileinput}=1;
		}
		if ($arg =~ /str\./){
			$importHash{string}=1;
		}
	}
	
	my $importString="";
	for my $arg (keys %importHash){
		$importString = "$importString,$arg";
	}

	$importString =~ s/^,//;
	
	if($importString){
		splice @$pyArrayRef,$importAddIndex,0,"import $importString\n";
	}
}

#introduce global variable into python program
sub introduceGlobalVariable{
	my $hashRef = $_[0];
	my $insertIndex=0;

	foreach my $a (@pythonArray){
		if($a =~ /^\s*\#/ or $a =~ /^\s*import/){
			$insertIndex++;	
			next;
		}else{
			last;
		}
	}

	foreach my $var (keys %$hashRef){
		##ignore value 2,4,6
		#no $insertIndex++ after insert, do not need to increase insert position
		#print "$var\n";
		if(${$hashRef}{$var}==1){
			splice @pythonArray,$insertIndex,0,"$var={}\n";
		}elsif(${$hashRef}{$var}==3){
			splice @pythonArray,$insertIndex,0,"$var=[]\n";
		}elsif(${$hashRef}{$var}==5){
			splice @pythonArray,$insertIndex,0,"$var=\"\"\n";
		}
	}
}


sub checkTypeCast{
	my $needToCastFlag=0;

	#1 means haven't cast, 2means casted
	#my %needToCastVar={};

	my $insertCastIndex=0;

	foreach my $arg (@pythonArray){
		if($arg =~ /(\s*)(\w+)\s*=\s*sys.stdin.readline()/){
			$needToCastFlag=1;
			if(not $needToCastVar{$2}){
				$needToCastVar{$2}=1;
			}
			$insertCastIndex++;
			next;
		}
		#print "$needToCastFlag\n";
		#print "$needToCastVar{number}\n";
		if($needToCastFlag){
			if($arg =~ /^(\s*)[^\$]*\s*\$(\w+)\s*(\>\=|\<\=|\<|\>|\=\=)\s*[0-9]+\.[0-9]*/){
				#print "$1\n$2\n$3\n$4\n";
				my $indent=$1;
				my $varName=$2;
				#print $indent."$varName=float($varName)\n";
				if($needToCastVar{$varName} and $needToCastVar{$varName}==1){
					#push @pythonArray, $indent."$varName=float($varName)\n";
					splice @pythonArray,$insertCastIndex,0,$indent."$varName=float($varName)\n";
					$needToCastVar{$varName}=2;
					$insertCastIndex++;
				}
			}elsif($arg =~ /^(\s*).*?\$(\w+)\s*[\+\-\*\%\/]\s*[0-9]+\.[0-9]+/){
				my $indent=$1;
				my $varName=$2;
				if($needToCastVar{$varName} and $needToCastVar{$varName}==1){
					#push @pythonArray, $indent."$varName=float($varName)\n";
					splice @pythonArray,$insertCastIndex,0,$indent."$varName=float($varName)\n";
					$needToCastVar{$varName}=2;
					$insertCastIndex++;
				}
			}elsif($arg =~ /^(\s*).*?\s*(\w+)\s*(\>\=|\<\=|\<|\>|\=\=)\s*[0-9]+/){
				my $indent=$1;
				my $varName=$2;
				#print "here\n";
				#print "$1\n,$2\n";
				#print "$varName\n";
				if($needToCastVar{$varName} and $needToCastVar{$varName}==1){
					#push @pythonArray, $indent."$varName=int($varName)\n";
					splice @pythonArray,$insertCastIndex,0,$indent."$varName=int($varName)\n";
					$needToCastVar{$varName}=2;
					#++ since push make current sentence index increase 1
					$insertCastIndex++;
				}
			}elsif($arg =~ /^(\s*).*?\$(\w+)\s*[\+\-\*\%\/]\s*[0-9]+/){
				my $indent=$1;
				my $varName=$2;
				if($needToCastVar{$varName} and $needToCastVar{$varName}==1){
					#push @pythonArray, $indent."$varName=int($varName)\n";
					splice @pythonArray,$insertCastIndex,0,$indent."$varName=int($varName)\n";
					$needToCastVar{$varName}=2;
					$insertCastIndex++;
				}
			}
			$insertCastIndex++;		
		}else{
			$insertCastIndex++;
			next;
		}		
	}
}

sub translateSub{
	my $insertIndex=0;
	foreach my $arg (@pythonArray){
		if($arg =~ /^\s*sub/){
			my $functionName=$pythonArray[$insertIndex];
			my $parameters=$pythonArray[$insertIndex+1];
			$functionName =~ s/sub\s([^\{]+)\{/$1/;
			chomp $functionName;
			chomp $parameters;
			$parameters =~ s/(my)*\s*([^\=]+)\=\s*\@\_/$2/;
			$parameters =~ s/\(//;
			$parameters =~ s/\)//;
			$parameters =~ s/\@//g;
			$parameters =~ s/\$//g;
			
			#print "$functionName $parameters\n";
			splice @pythonArray,$insertIndex,2,"def $functionName\($parameters\):\n"			
		}
		$insertIndex++;
	}
}

#clarification for %variableHash usage
###record variable, see if it need to be declared before using
###val 1 stands for global hash,val2 stands for local hash, val 3 stands for global array, val4 local array,
###val5 global variable, val6 local variable
#%variableHash={};

##in most case , parenthesis is retained
while ($line = <>) {
	############################ pre-processing #####################

	#chomp each line, so when output, plus \n
	chomp $line;

	#remove the $ from variable
	#$line =~ s/\$//g;

	#remove the ; 
	$line =~ s/;$//;

	#change && to and
	$line =~ s/\&\&/ and /;
	#change || to or
	$line =~ s/\|\|/ or /;
	#in perl, eq used for string compare
	#change eq to ==
	$line =~ s/eq/==/;

	#change @ARGV to sys.argv
	$line =~ s/\@ARGV/sys\.argv[1:]/;
	#change $ARGV[] to sys.argv[]
	$line =~ s/\$ARGV/sys\.argv/;
	#change $#ARGV to len(sys.argv)
	$line =~ s/\$#ARGV/len(sys\.argv)/;
	#print "\$line:$line\n";
	#tranlate ?#lines for every condition
	$line =~ s/\$\#(\w+)/len($1)\-1/;

	#change to process it in @pythonArray
	#if there is going be a number comparison, cast the string to a number
	#used to solve the case $number = <STDIN>; if ($number >= 0) {.......
	#it must cast string to a number
	#if($line =~ /^(\s*).*?\s*\$(\w+)\s*[\>|\<|\=][\>|\<|\=]*\s*[0-9]+\.[0-9]*/){
	#	my $indent=$1;
	#	my $varName=$2;
	#	#print $indent."$varName=float($varName)\n";
	#	push @pythonArray, $indent."$varName=float($varName)\n";
	#}elsif($line =~ /^(\s*).*?\$(\w+)\s*[\+\-\*\%\/]\s*[0-9]+\.[0-9]+/){
	#	my $indent=$1;
	#	my $varName=$2;
	#	push @pythonArray, $indent."$varName=float($varName)\n";
	#}elsif($line =~ /^(\s*).*?\s*[\$\@](\w+)\s*(\>\=)|(\<\=)|(\<)|(\>)|(\=\=)\s*[0-9]+/){
	#	my $indent=$1;
	#	my $varName=$2;
	#	push @pythonArray, $indent."$varName=int($varName)\n";
	#}elsif($line =~ /^(\s*).*?\$(\w+)\s*[\+\-\*\%\/]\s*[0-9]+/){
	#	my $indent=$1;
	#	my $varName=$2;
	#	push @pythonArray, $indent."$varName=int($varName)\n";
	#}

	#$0 is a special case correspond to sys.argv[0]
	if($line =~ /\$0/){
		$line =~ s/\$0/sys.argv[0]/;
	}
	#process $1,$2...
	if($line =~ /\$\d/){
		my @matches = ($line =~ /\$[1-9]/g);
		#my $i=1;
		#print "@matches\n";		
		for my $m (@matches){
			my $i = $m;
			$i =~ s/\$//;
			$line =~ s/\Q$m\E/matchGroup.group($i)/;
			#$i++;
		}
	}


	#translate concatenation sign .
	if($line =~ /\.\=/){
		$line =~ s/\.\=/\+\=/;
	}
	#to deal with $xx."" or "".$xx or $xx.$xx or "".""
	if($line =~ /((\$[^ ]*?)|(\"[^\"]*?\"))\s*(\.)\s*((\$[^ ]*?)|(\"[^\"]*?\"))/){
		#$line =~ s/((\$[^ ]*?)|(\"[^\"]*?\"))\s*(\.)\s*((\$[^ ]*?)|(\"[^\"]*?\"))/$1\+$5/g;
		#print "$line\n";
		#print "$1\n$2\n$3\n$4\n$5\n$6\n$7\n";
		if($1 and $5){
			$line =~ s/((\$[^ ]*?)|(\"[^\"]*?\"))\s*(\.)\s*((\$[^ ]*?)|(\"[^\"]*?\"))/$1\+$5/;
		}elsif($1 and $6){
			$line =~ s/((\$[^ ]*?)|(\"[^\"]*?\"))\s*(\.)\s*((\$[^ ]*?)|(\"[^\"]*?\"))/$1\+$6/;
		}elsif($2 and $5){
			$line =~ s/((\$[^ ]*?)|(\"[^\"]*?\"))\s*(\.)\s*((\$[^ ]*?)|(\"[^\"]*?\"))/$2\+$5/;
		}elsif($2 and $6){
			$line =~ s/((\$[^ ]*?)|(\"[^\"]*?\"))\s*(\.)\s*((\$[^ ]*?)|(\"[^\"]*?\"))/$2\+$6/;
		}
	}

	########################## instant processing ####################

	#any process put in this block, should not has any consecutive process
    	if ($line =~ /^#!/ && $. == 1) {
		# translate #! line 
        	#print "#!/usr/local/bin/python3.5 -u\n";
		push @pythonArray,"#!/usr/local/bin/python3.5 -u\n";
		#print "import sys\n";
		#print "import fileinput\n";
		#print "import re\n";
		next;
    	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
    
        	# Blank & comment lines can be passed unchanged
        
       		#print "$line\n";
		push @pythonArray,"$line\n";
		next;
    	} elsif($line =~ /(\s*)[}]*\s*else\s*[{]*/){
		#deal with well-structured else	
		#print $1."else:\n";
		push @pythonArray, $1."else:\n";
		next;
	} elsif($line =~ /(\s*)[}]*\s*elsif\s*\((.*)\)[{]*/){
		#deal with well-structured elsif
		$indent = $1;
		$condition = $2;
		$condition =~ s/\$//g;
		#print $indent."elif $condition:\n";
	        push @pythonArray,$indent."elif $condition:\n";
		next;
	} elsif($line =~ /^\s*}\s*$/){
		#ignore the } 
		next;		
	} elsif($line =~ /chomp/){
		#change chomp to strip(), $ sign left to following program
		$line =~ s/chomp (.*)/$1=$1\.rstrip\(\)/;
		$line =~ s/\$//g;
		#print "$line\n";
		push @pythonArray,"$line\n";
		next;
	} elsif($line =~ /next/){
		#change next to continue
		$line =~ s/next/continue/;
		#print "$line\n";
		push @pythonArray,"$line\n";
		next;
	} elsif($line =~ /last/){
		#change last to break
		$line =~ s/last/break/;	
		#print "$line\n";
		push @pythonArray,"$line\n";
		next;
	} elsif($line =~ /(\s*)(\$\w+)\+\+$/){
		#deal with pure ++, not in for statement
		my $indent = $1;
		my $varName = $2;
		#print $indent."$varName = $varName+1\n";
		$line = $indent."$varName = $varName + 1\n";
		#push @pythonArray,$indent."$varName = $varName + 1\n";
		#next;
	} elsif($line =~ /(\s*)(\$\w+)\-\-$/){
		#deal with pure --, not in for statement
		my $indent = $1;
		my $varName = $2;
		#print $indent."$varName = $varName-1\n";
		$line = $indent."$varName = $varName - 1\n";
		#push @pythonArray,$indent."$varName = $varName - 1\n";
		#next;
	} elsif($line =~ /(\s*)\$(\w+)\s*=~\s*([a-z]+)\/([^\/]+)\/([^\/]*)\/([a-z]*)/){
		#deal with $line =~ [s]///[g]; 
		#if($6){
		#	print "\$1:$1\n";
		#	print "\$2:$2\n";
		#	print "\$3:$3\n";
		#	print "\$4:$4\n";
		#}else{
		#	print "\$1:$1\n";
		#	print "\$2:$2\n";
		#	print "\$3:$3\n";
		#}
		#last;
		if($6){
			#print "\$6:$6\n";
			equalTildeProcess($1,$2,$3,$4,$5,$6);	
		}else{
			equalTildeProcess($1,$2,$3,$4,$5);
		}
		next;
	} elsif($line =~ /(\s*)\$(\w+)\s*=~\s*\/([^\/]*)\//){
		#$line =~ /(\s*)if\s*\(\s*\$(\w+)\s*=~\s*\/([^\/]*)\/\)/ or 
		#match if $x=~ /.../
		#haven't include $matches=($x =~ /.../)
		#deal with $line =~ //
		my $indent = $1;
		my $varName = $2;
		my $pattern = $3;
		$line =~ s/\$(\w+)\s*=~\s*\/([^\/]*)\// re.match("$pattern",$varName)/;
		## when you meet match case, there could be $1 $2 then
		## in order to use matchGroup.group() 
		## use matchGroup as match name here
		$line =~ s/\(//;
		$line =~ s/\)\s*\{//;
		#print "$line:\n";
		push @pythonArray,"$line:\n";
		#print $indent."\t"."matchGroup=re.match('$pattern',$varName)\n";
		push @pythonArray, $indent."\t"."matchGroup=re.match('$pattern',$varName)\n";
		next;
	} elsif($line =~ /(\s*)open\s*(\w+),\s*\"\<(.*)\"/){
		##match open F, "<...", read
		#print "$1$2=open('$3','r')\n";
		push @pythonArray,"$1$2=open('$3','r')\n";
		next;
	} elsif($line =~ /(\s*)open (\w+),\s*\"\>(.*)\"/){
		#match open > , write
		#print "$1$2=open('$3','w')\n";
		push @pythonArray,"$1$2=open('$3','w')\n";
		next;
	} elsif($line =~ /(\s*)open\((\w+),(.*)\)/){
		push @pythonArray,"$1$2=open('$3','wr')\n";
		next;
	} elsif($line =~ /(\s*)close\s*(\w+)/){
		#match close F;
		#print "$1$2.close()\n";
		push @pythonArray,"$1$2.close()\n";
		next;
	} elsif($line =~ /\@(\w+)\s*\=\s*\(([^\)]+)\)/){
		## assign value to @array , @array = (...) 
		$line =~ s/\@(\w+)\s*\=\s*\(([^\)]+)\)/$1=\[$2\]/;
		#print "$line\n";
		push @pythonArray,"$line\n";
		next;
	} elsif($line =~ /^(\s*)exit\s*(\d+)?/){
		my $indent =$1;
		if($2){
			#print $indent."sys.exit($2)\n";
			push @pythonArray, $indent."sys.exit($2)\n";
		}else{
			#print $indent."sys.exit()\n";
			push @pythonArray, $indent."sys.exit()\n";
		}
		next;				
	}

	
	################### consecutive processing ##############################

	##### has indent without my keyword means that could be a global variable
	if($line =~ /^(\s)+/ and $line =~ /[\$|\%|\@]/ ){
		##if proceeded with my keyword, means it is local variable, 
		##for python , default scope is local
		##I don't need it, but have to record it 
		if($line =~ /my [\$|\%|\@]/){
			my @matches = ($line =~	/[\$|\%|\@]([^ \s,;\\\/\)\]\+\=\-\<\>]+)/g);
			foreach my $a (@matches){
				if ($a =~ /\@\_/){
					next;
				}
				#here could be push or some other operations
				if($a =~ /\@/){
					$a=~s/\@//;
					#print "$a\n";
					if(not $variableHash{$a}){
						$variableHash{$a}=3;
					}
				}
				if($a =~ /\%/){
					$a=~s/\%//;
					if(not $variableHash{$a}){
						$variableHash{$a}=1;
					}
				}
				$a =~ s/\$//;
				#circumstance like $hash{$index} $array[$index]
				if($a =~ /([^ ,\s]+)\{/){
					#it's a hash variable
					if(not $variableHash{$1}){
						$variableHash{$1}=2;
					}
				}elsif($a =~ /([^ ,\s]+)\[/){
					#it's a array variable
					if(not $variableHash{$1}){
						$variableHash{$1}=4;
					}
				}else{
					#common variable
					if(not $variableHash{$a}){
						$variableHash{$a}=6;
					}
				}	
			}				
		}else{
			my @matches = ($line =~	/[\$|\%|\@][^ \s,;\\\/\)\]\+\=\-\<\>]+/g);
			#print "@matches\n";
			foreach my $a (@matches){
				if ($a =~ /\@_/){
					next;
				}
				if($a =~ /\@/){
					$a=~s/\@//;
					#print "$a\n";
					if(not $variableHash{$a}){
						$variableHash{$a}=3;
					}
				}
				if($a =~ /\%/){
					$a=~s/\%//;
					if(not $variableHash{$a}){
						$variableHash{$a}=1;
					}
				}
				$a =~ s/\$//;
				#do not need to worry about index is a variable here, since
				#index variable will be assigned before use it, you can detect it
				#with variable detect
				if($a =~ /([^ ,\s]+)\{/){
					#it's a hash variable
					if(not $variableHash{$1}){
						$variableHash{$1}=1;
					}
				}elsif($a =~ /([^ ,\s]+)\[/){
					#it's a array variable
					if(not $variableHash{$1}){
						$variableHash{$1}=3;
					}
				}else{
					if(not $variableHash{$a}){
						$variableHash{$a}=5;
					}
				}
			}
			#print keys %variableHash, "\n";	
		}
	}
	
	#remove my keyword
	$line =~ s/(.*)my\s/$1/;
	
	#start with a $ means it's a declaration/assignment, simply remove the $ but, here do not next; 
	#since could be $line =<STDIN> , foreach $arg (@ARGV)
	#remove all the $ in a sentence
	#we can't do the same thing to @,%
	if ($line =~ /^\s*\$/ && not $line =~ /\$\w+\{\$\w+\}/ ){	
		$line =~ s/\$//g;
		#print "$line\n";
	}

	if($line =~ /\@(\w+)\s*\=\s*/){
		## could be @array = sys.stdin.readline()
		$line =~ s/\@//;
		#print "$line\n";
		#next;
	}

	##change $hash{$index} to hash[index]
	if ($line =~ /\$\w+(\{\$\w+\})+/){
		#$line =~ s///g;
		$line =~ s/\$(\w+)\{/$1\[/;
		$line =~ s/\[\$/\[/;
		$line =~ s/\{\$/\[/g;
		$line =~ s/\}/\]/g;
		#$line =~ s/\$(\w+)\{\$(\w+)\}/$1\[$2\]/g;
	}elsif($line =~ /\$?[^\{\}]+\{[^\{\}\$]+\}/){
		#print "here";
		$line =~ s/\$?([^\{\}]+)\{\$*([^\{\}]+)\}/$1\[$2\]/g;
		#print "$line\n";
	}
	##change $array[$index] to array[index]
	if ($line =~ /\$\w+\[\$\w+\]/){
		$line =~ s/\$(\w+)\[\$(\w+)\]/$1\[$2\]/g;
	}
	
	##it's a dict[]++, list[]++, then the defualt is undef
	if ($line =~ /(\s*)(\w+)\[(\w+)\]\+\+/){
		my $indent = $1;
		my $dictName = $2;
		my $indexName =$3;
		#print $indent."if $indexName in $dictName:\n";
		push @pythonArray,$indent."if $indexName in $dictName:\n";
		#print $indent."\t"."$dictName"."[$indexName]".'+=1'."\n";
		push @pythonArray,$indent."\t"."$dictName"."[$indexName]".'+=1'."\n";
		#print $indent."else:\n";
		push @pythonArray, $indent."else:\n";
		#print $indent."\t"."$dictName"."[$indexName]".'=1'."\n";
		push @pythonArray,$indent."\t"."$dictName"."[$indexName]".'=1'."\n";
		next;
	}

	#translate join
	#do not need next;
	#could be a circumtance print join('',@ARGV);
	if($line =~ /join\((\'.*\'),\s*(.*)\)/){
		#join(' ',@list);
		my $delimiter = $1;
		my $list = $2;
		$line =~ s/join\(.*\)/$delimiter\.join\($list\)/;
	}elsif($line =~ /join \"[^\"]*\",\s*(.*)/){
		#join " ",@list; in this form 
		my $delimiter = $1;
		my $list = $2;
		$line =~ s/join\(.*\)/$delimiter\.join\($list\)/;
	}
	#translate split
	if($line =~ /split\((\'.*\'),\s*(.*)\)/){
		#split('', $data);
		my $delimiter = $1;
		my $list = $2;
		$line =~ s/split\(.*\)/$list\.split\($delimiter\)/;
	}elsif($line =~ /split\(\/(.*)\/,\s*(.*)\)/){
		#split(/\d+/,$data)
		my $delimiter = $1;
		my $list = $2;
		$line =~ s/split\(.*\)/$list\.split\($delimiter\)/;
	}elsif($line =~ /\s*split\s*\/([^\/]*)\/\s*,\s*(.*)/){
		#print "here\n";
		#split //,$line;
		my $delimiter=$1;
		my $list=$2;
		$list =~ s/\$//;
		$line =~ s/split\s*\/([^\/]*)\/\s*,\s*(.*)/$list\.split\('$delimiter'\)/;
	}


	##translate while(@lines), @lines is under scalar context, so I change to the length
	if($line =~ /(\s*)while\s*\(\s*\@(\w+)\s*\)\s*\{/){
		my $indent = $1;
		my $list = $2;
		$line = $indent."while len($list):\n";
		push @pythonArray,$line;
		next; 
	}

	#translate while($line = <>)
	#should be put in front of one line <STDIN> and common while 
	#import fileinput as default
	if($line =~ /(\s*)while\s*\(\s*(\$\w*)\s*=\s*\<\>\s*\)/){
		my $indent=$1;
		my $varName=$2;
		$varName=~s/\$//;
		#print $indent."for $varName in fileinput.input():\n";
		push @pythonArray,$indent."for $varName in fileinput.input():\n";
		next;
	}elsif($line =~ /(\s*)while\s*\(\s*(\$\w*)\s*=\s*\<STDIN\>\s*\)/){
		#for circumstance where while($line=<STDIN>)
		my $indent=$1;
		my $varName=$2;
		$varName=~s/\$//;
		#print $indent."for $varName in fileinput.input():\n";
		push @pythonArray,$indent."for $varName in fileinput.input():\n";
		next;
	}elsif($line =~ /(\s*)while\s*\(\s*\$(\w+)\s*=\s*\<(\w+)\>\s*\)/){
		##translate while($line = <F>)
		#print $1."for $2 in $3:\n";
		push @pythonArray,$1."for $2 in $3:\n";
		next;
	}elsif($line =~ /<STDIN>/){
		#it's circumstance with single line as $line =<STDIN>
		$line =~ s/<STDIN>/sys\.stdin\.readline\(\)/;
	}
	
	#common while statement and if statement
	if ($line =~ /while/ || $line =~ /[\W\s]?if[\W\s]/){
		#remove $ sign
		$line =~ s/\$//g;
		#remove the () and {, add :
		$line =~ s/\(/ /;
		$line =~ s/\)\s*{//;
		#$line =~ s/{//;
		#print "$line:\n";
		push @pythonArray,"$line:\n";
		next; 
	}


	#translate (sort keys %hash)
	if($line =~ /sort keys %\w+/){	
		#sort keys %count
		$line =~ s/sort keys %(\w+)/sorted($1.keys())/;
	}elsif($line =~ /keys %\w+/){
		$line =~ s/keys %(\w+)/$1.keys()/;
	}
	##translate reverse, should be put before print reverse @lines
	##or foreach $arg (reverse @lines)  , reverse keys %hash
	if($line =~ /reverse\s*[\W\w]+/){
		$line =~ s/reverse\s*([\W\w]+)/$1\[::\-1\]/;
		$line =~ s/\@//;
	}

	##translate pop,push,shift,unshift
	##anything looks like $a=pop @names or pop @ARGV(@ARGV already been changed to sys.argv)
	##\W+ match the @, so here get rid of @ implicitly, 
	if($line =~ /pop\s*(\W*)(\w+)/){
		### could be pop (keys %hash), pop @names
		$line =~ s/pop\s*(\W*)(\w+)/$2.pop()/;		
	}elsif($line =~ /push\s*(\W)*(\w)+\s*,\s*(.*)/){
		$line =~ s/push\s*(\W)*(\w+)\s*,\s*(.*)/$2.append($3)/;
	}elsif($line =~ /unshift\s*(\W)*(\w+)\s*,\s*\$?(.*)/){
		$line =~ s/unshift\s*(\W)*(\w+)\s*,\s*\$?(.*)/$2.insert(0,$3)/;
	}elsif($line =~ /shift\s*(\W*)(\w+)/){
		$line =~ s/shift\s*(\W*)(\w+)/$2.pop(0)/;
	}

	#foreach translate, correspoding in python could be for ... in ...
	#remember , $ sign hasn't been removed, previous program just remove $ when $ sign is on the beginning of the line 
	if($line =~ /^(\s*)foreach (\$[^ ]+) \(\@?([a-zA-Z]+.*)\)/){		
		#translate for $arg (@array)
		my $indent = $1;
		my $arg = $2;
		my $list = $3;
		$arg =~ s/\$//g;
		$list =~ s/\$//g;
		#print $indent."for $arg in $list:\n";
		push @pythonArray,$indent."for $arg in $list:\n";
		next;
	}elsif($line =~ /(\s*)foreach (\$[^ ]+) \(([0-9]+.*)\)/){
		#translate for $arg (0..5)
		#it is a range 
		#python range doesn't contain the stop number however perl does contain
		my $indent = $1;
		my $arg = $2;
		my $list = $3;
		$arg =~ s/\$//;
		#my @matchNumbers = ($list =~ /[0-9]+/ng );
		if($list =~ /len\(sys\.argv\)/){
			#a special case for $arg (0..$#ARGV)
			#$#ARGV has been changed to len(sys.argv)
			$list =~ /([0-9]+)\.\.(.*)/;
			if($1 == 0){
				#print "for $arg in range(1,$2):\n";
				push @pythonArray,$indent."for $arg in range(1,$2):\n";
			}else{
				#print "for $arg in range($1,$2):\n";	
				push @pythonArray,$indent."for $arg in range($1,$2):\n";		
			}
			next;
		}else{
			$list =~ /([0-9]+)\.\.(.*)/;
			#my $pythonStopNumber = $matchNumbers[1]+1;
			#print "for $arg in range($matchNumbers[0],$pythonStopNumber)\n";
			#print $indent."for $arg in range($1,$2+1):\n";
			push @pythonArray,$indent."for $arg in range($1,$2+1):\n";
			next;
		}
	}

	##change c like for statement
	if($line =~ /(\s*)for\s*\(\s*([^;]*?);([^;]*?);([^;]*?)\s*\)/){
		my $indent=$1;
		my $c1=$2;
		my $c2=$3;
		my $c3=$4;
		if($c3 =~ /\-\-/){
			my $higherBond =$c1;
			my $lowerBond= $c2;
			$higherBond =~ s/.*?\s*[\=]\s*(.*)/$1/;
			$lowerBond =~ s/.*?\s*[\<|\<\=]\s*(.*)/$1/;
			my $loopVarName = $c1;
			$loopVarName =~ s/(.*?)\s*[\=]\s*(.*)/$1/;
			$loopVarName =~ s/\$//;
			#print $indent."for $loopVarName in reversed(range($lowerBond,$higherBond)):\n";
			push @pythonArray, $indent."for $loopVarName in reversed(range($lowerBond,$higherBond)):\n";
			next;
		}else{
			my $lowerBond =$c1;
			my $higherBond= $c2;
			$lowerBond =~ s/.*?\s*[\=]\s*(.*)/$1/;
			$higherBond =~ s/.*?\s*[\<|\<\=]\s*(.*)/$1/;
			my $loopVarName = $c1;
			$loopVarName =~ s/(.*?)\s*[\=]\s*(.*)/$1/;
			$loopVarName =~ s/\$//;
			#print $indent."for $loopVarName in range($lowerBond,$higherBond):\n";
			push @pythonArray, $indent."for $loopVarName in range($lowerBond,$higherBond):\n";
			next;
		}
	}

	#inside print, there could be other process such as join, so put the print command in the end
	#process the print command
	if($line =~ /^(\s*)printf\s*(.*)[\s;]*$/){
		printProcess($line,$1,$2);
		next;
	} elsif ($line =~ /^(\s*)print\s*(.*)[\s;]*$/) {
		#"print" function transform
		printProcess($line,$1,$2);  
		next;      		

   	}
	#if a line is processed by many blocks, print out the $line in the end
	#print "$line\n";
	push @pythonArray,"$line\n";

	#put in the final if block
	#else {
        	# Lines we can't translate are turned into comments
        
        #	print "#$line\n";
    	#}
}


importStatement(\@pythonArray);

introduceGlobalVariable(\%variableHash);

checkTypeCast();

translateSub();

##print out @pythonArray
while(@pythonArray){
	my $output=shift @pythonArray;
	$output =~ s/\$//g;
	print $output;
}
















	
