package Bibl::Modules::List;

use base Bibl::Core;

sub begin {
    return 1;
}

sub process {
    my ($self, $params) = @_;
    $self->{template}='bibl.tmpl';

    my $desc = 'asc';
    my $order_by = 'item';
    my @search_lang = (1 => 1);
    my @search_atype = ( 'me.type' => 1 );

    if ($self->{params}->{type}) {
	if ($self->{params}->{lang} eq 'en') {
	    @search_lang = ( 'lang' => 'en' );
	} elsif ($self->{params}->{lang} eq 'ru') {
	    @search_lang = ( 'lang' => 'ru' );
	}

	if ($self->{params}->{type} eq 'books') {
	    @search_atype = ( 'me.type' => 2 );
	} elsif ($self->{params}->{type} eq 'sel') {
	    @search_atype = ( 'me.type' => 2 );
	}

	my @articles = $self->{schema}->resultset('BiblArticle')->search(
	    { @search_lang, @search_atype },
	    { join => ('map_edition'),
	    prefetch => ({'map_edition' => 'map_journal'}),
	    order_by => {"-$desc" => $order_by} }
	)->all;

	$self->{stash}->{articles} = \@articles;
    } else {
	$self->{stash}->{default} = 1;
    }
}

1;
