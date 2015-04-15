package Bibl::Session;

use CGI;
use CGI::Cookie;

use DBI;
use Bibl::Config qw($conf);

my $CN = 'BIBL_SESSIONID';
my $USER_TABLE = 'jos_users';
my $SESS_TABLE = 'bibl_sessions';

my $DEF_SESSION_TIME = 8*3600; # 8 hours by default
my $LONG_SESSION_TIME = 14*24*60*60; # remember for 2 weeks

sub new {
    my ($class, $params) = @_;

    my %cookies = fetch CGI::Cookie;

    my $data_source = "dbi:mysql:database=".$conf->{db_name}.";host=".$conf->{db_host};
    my $dbh = DBI->connect($data_source, $conf->{db_login}, $conf->{db_pass}) or die ($DBI::errstr);

    my $self = {
        dbh => $dbh,
        params => $params
    };
    bless ($self => $class);

    if (exists $cookies{$CN}) {
        $self->{'id'} = $cookies{$CN}->value;
        $self->check_id;
    }

    return $self;
}

sub dbh {
    my ($self) = @_;
    return $self->{dbh};
}

sub status {
    my ($self) = @_;
    if ($self->{'is_logged'}) {
        return 1;
    }
    else {
        return 0;
    }
}

sub get_userid {
    my ($self) = @_;
    if ($self->{'is_logged'}) {
        return $self->{'userid'};
    }
}

sub check_id {
    my ($self) = @_;
    $self->{'is_logged'} = 0;
    my $user = $self->{'dbh'}->selectall_arrayref("SELECT user_id FROM $SESS_TABLE WHERE md5(session_key) = md5(?) AND remote_ip=?",
        undef, $self->{'id'}, $ENV{'REMOTE_ADDR'});
    if ($$user[0][0]) {
        $self->{'is_logged'} = 1;
        $self->{'userid'} = $$user[0][0];
        # load user info
        # $self->{'userinfo'} = $uinfo;
    }
}

sub login {
    my ($self) = @_;
    # check if login and password correct

    my ($dbh, $username, $password) = (
        $self->{dbh}, 
        $self->{params}->{login}, 
        $self->{params}->{pass}
    );

    my $row = $dbh->selectrow_arrayref("
        SELECT id, password FROM jos_users WHERE username = ?",
    undef,
    $username);

    my ($hash, $salt) = split(/:/, $row->[1]);
    my $now = time;

    my $md5 = $dbh->selectrow_arrayref("
        SELECT MD5(CONCAT(?,?))", 
        undef, 
    $password, $salt);

    if ($md5->[0] eq $hash) {
        my $session_time = $self->{'params'}->{'remember'} ? $LONG_SESSION_TIME : $DEF_SESSION_TIME;
        my $sessid = $self->gen_sessid;
        my $sth = $self->{'dbh'}->prepare("
            INSERT INTO $SESS_TABLE (session_key, user_id, expires, remote_ip)
            VALUES (?, ?, FROM_UNIXTIME($now+$session_time), ?)");
        $sth->execute(
            $sessid,
            $row->[0],
            $ENV{'REMOTE_ADDR'});
        $self->{'is_logged'} = 1;
        $self->{'id'} = $sessid;
    }
}

sub id {
    my ($self) = @_;
    return $self->{'id'};
}

sub header { # Only called just after login
    my ($self) = @_;
    my $cgi = new CGI;
    my $redirect = 'manage.cgi'; # or param (redir_to) if defined

    if ($self->{'id'} && $self->{'is_logged'}) {

    my $expire = $self->{'params'}->{'remember'} ? $LONG_SESSION_TIME : $DEF_SESSION_TIME;
    $expire = int ($expire/3600); # convert seconds to hours

    my $cookie = new CGI::Cookie(-name=>$CN,
            -value=>$self->{'id'},
            -expires=>'+'.$expire.'h');
    return $cgi->header (
            -type => 'text/html',
            -'charset'=>'UTF-8',
            -cookie=>$cookie,
            -refresh => '0; URL='.$redirect); # here referer instead of admin.cgi
    }
    else {
        return $cgi->header (
            -type => 'text/html',
            -'charset'=>'UTF-8',
            -refresh => '0; URL='.$redirect
        );
    }
}

sub logout {
    my ($self) = @_;
    if ($self->{'is_logged'} == 1) {
        my $sth = $self->{'dbh'}->prepare("DELETE FROM $SESS_TABLE WHERE session_key = ? AND remote_ip=?");
        $sth->execute($self->{'id'}, $ENV{'REMOTE_ADDR'});
    }
    $self->{'is_logged'} = 0;
    # delete from sessions table where sess_id = $self->{'id'};
    # create new cookie
    # do logout
}

sub gen_sessid {
    my ($self) = @_;

    my $md5 = $self->{dbh}->selectrow_arrayref("SELECT CONCAT(MD5(UUID()),MD5(UUID()))");

    return $md5->[0] if ($md5->[0]);

    my @alphanumeric = ('a'..'z', 'A'..'Z', 0..9);
    my $rand_sessid = join '',
    map $alphanumeric[rand @alphanumeric], 0..50;

    return $rand_sessid;
}

1;
