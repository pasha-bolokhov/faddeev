package Bibl::Modules::Index;

use base Bibl::Core;

sub begin {
    return 1;
}

sub process {
    my ($self, $params) = @_;

    my %pages = (
	'cv' => 1,
	'self' => 1,
	'misc' => 1,
	'media' => 1,
	'links' => 1,
    );

    my $menu = $self->{params}->{menu};
    my $page = $self->{params}->{page};

    $menu =~ s/\s//g;
    if ($menu =~ m/[a-zA-Z0-9]+/) {
	$self->{stash}->{menu} = $menu;
    } else {
	$self->{stash}->{menu} = 'main';
    }

    $page =~ s/\s//g;
    if ($page =~ m/[a-zA-Z0-9]+/ && $pages{$page} == 1) {
	$self->{template} = $page . '.tmpl';
    } else {
	$self->{template}='index.tmpl';
    }
    
}

1;
