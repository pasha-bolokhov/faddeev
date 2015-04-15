package Bibl::Core;

use strict;

use Bibl::Config qw($conf);
use Bibl::Schema;
##use Bibl::Session;

use Template;

use utf8;

sub new {
    my ($class, $params) = @_;

##    my $session = Bibl::Session->new($params);

    my $self = {
        conf    => $conf,
##        session => $session,
##        dbh     => $session->dbh,
        params  => $params,
        stash   => {},  # hash to hold HTML::Template params and values
        schema  => Bibl::Schema->connect (
                "dbi:mysql:database=".$conf->{db_name}.";host=".$conf->{db_host},
                $conf->{db_login},
                $conf->{db_pass}, {
                    Callbacks => {
                        connected => sub {
                        shift->do(q{ SET NAMES utf8; });
                        return;
                    }
                }
        })
    };

    bless $self => $class;
    return $self;
}

sub new_nodb {
    my ($class, $params) = @_;
    my $self = {
	params  => $params,
        stash   => {},  # hash to hold HTML::Template params and values
    };
    bless $self => $class;
    return $self;
}

sub login {
    my ($self) = @_;
}

sub logout {
    my ($self) = @_;
}

sub begin {
    my ($self,$params) = @_;

    # DO NOT procced further
    # Comment ONLY if session is defined above
    return 1;
    # check session here etc.
    unless ($self->{session}->status) {
        # show login form
        $self->{template} = 'login_form.tmpl';
        $self->end;
    }

    my $user_id = $self->{session}->get_userid;
}

sub process {
    my ($self) = @_;
    # default page
}

sub end {
    my ($self) = @_;
    my $template = Template->new ( {
        INCLUDE_PATH => "/home/site/tmpl/"
    });
    my $file = $self->{template} || 'index.tmpl';

#       use Data::Dumper;
#       die Dumper($self->{stash}->{items});

    my $content_type = $self->{content_type} || "text/html";
    print "Content-Type: $content_type; charset=utf-8\n\n";

    $template->process($file, $self->{stash}) || die "Template process failed: ", $template->error();

    exit;
}

1;
