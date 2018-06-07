use LWP::Simple;
use Socket;
#use Net::DNS;

$doc = get('http://www.cybersyndrome.net/pla5.html');
@doc = split/\n/, $doc;

$flg = 0;
foreach $temp(@doc)
{
	#プロキシ行を抜き出す予定
	if($flg == 1)
	{
		$line = $temp;
		chomp $line;
		last;
	}
	if(($temp =~ /<ol>/))
	{
		$flg = 1;
	}
}

$line =~ s/<li>//g;
$line =~ s/<\/ol>//g;
$line =~ s/<\/a>//g;

@proxy_line = split/<\/li>/, $line;
@proxy_array;

foreach $temp(@proxy_line)
{
	@temp2 = split/>/, $temp;
	@temp3 = split/:/, $temp2[1];
	push @proxy_array, $temp3[0];
}

open IN, ".htaccess" or die "input open error $!";
@htaccess = <IN>;
close IN;

open OUT, ">.htaccessback.txt" or die "input open error $!";
print OUT @htaccess;
close OUT;

open ADD, ">>.htaccess" or die "output open error $!";

foreach $temp(@proxy_array)
{
#	if($temp =~ /a-zA-Z/)
	{
		$ip_add = inet_ntoa(inet_aton($temp));
	}
#	else
#	{
#		$ip_add = $temp;
#	}
	$deny_word = "deny from $ip_add";
	$match = 0;
	foreach $htaccess(@htaccess)
	{
		if(0 <= index($htaccess, $deny_word))
		{
			$match = 1;
			last;
		}
	}
	if($match == 0)
	{
		print ADD $deny_word . " # $temp";
		print ADD "\n";
	}
}

#$ip_add = inet_ntoa(inet_aton("ip-208-96-135-77.ni.amnetdatos.net"));
#open OUT, ">>address.txt" or die "output open error $!";
#print OUT $ip_add;
#close OUT;
