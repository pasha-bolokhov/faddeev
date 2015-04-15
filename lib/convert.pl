#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use lib qw(/home/site/lib);

use Bibl::Config qw($conf);
use Bibl::Schema;

my $schema  = Bibl::Schema->connect (
    "dbi:mysql:database=".$conf->{db_name}.";host=".$conf->{db_host},
    $conf->{db_login},
    $conf->{db_pass},
    { Callbacks => {
                        connected => sub {
			    shift->do(q{ SET NAMES cp1251; });
			    return;
			}
		    }
    }
);

open (DAT, '<', 'fadbib6.tex');

my $bib;
while (<DAT>) {
    s/%.*//;
    s/\\\\//g;
    s/\\ / /g;
    s/~/ /g;
    s/--/-/g;
    $bib .= $_;
}
close DAT;

$bib =~ s/([^\n])\n/$1 /g;

my @bibs = split('\n',$bib);

foreach my $b (@bibs) {
    my %art;
    $art{'lang'} = 'en';
    my %publ;
    my %jour;
    my ($edition, $rest);
    my $match = 0;
    #print "$b\n\n";

    if ($b =~ m/^\\bibitemrp{(\w+?)}\s*{(.*?)}\s*{(.*?)}\s*{(.*?)}\s*{(.*?)}\s*{(.*?)}\s*{(.*?)}\s*{(.*?)}\s*{(.*?)}/ ) {
	$art{'item'} = $1;
	$art{'lang'} = $2;
	$jour{'name'} = $3;
	$jour{'publisher'} = $4;
	$jour{'location'} = $5;
	$publ{'year'} = $6;
	$publ{'vol'} = $7;
	$publ{'pages'} = $8;
	$jour{'type'} = $9;
	$publ{'type'} = 2;
	#print "r Item: $art{'item'}, author: $art{'author'}, title: $art{'title'}\n";
	$match = 1;
    }

    if ($match == 1) {

	my $journal = $schema->resultset('BiblJournal')->search(
	    { -or => [ {abbr => $jour{'name'} }, {name => $jour{'name'} }] },
	    {rows => 1 }
	)->single;

	unless ($journal) {
	    $journal = $schema->resultset('BiblJournal')->create(\%jour);
	}
	$publ{'journal_id'} = $journal->id;

	my $article = $schema->resultset('BiblArticle')->find(
	    {item => $art{'item'}, lang => $art{'lang'}}, {rows => 1});
	if ($article) {
	    #print "Article $art{'item'} and lang $art{'lang'} already in DB!\n";
	} else {
	    print "Cannot find $art{'item'} and lang $art{'lang'}!\n";
	    #$article = $schema->resultset('BiblArticle')->create(\%art);
	}

	$publ{'article_id'} = $article->id;

	my $issue = $schema->resultset('BiblEdition')->find(\%publ);
	if ($issue) {
	    print "Issue $publ{'issue'} vol $publ{'vol'} year $publ{'year'} already in DB!\n";
	} else {
	    $issue = $schema->resultset('BiblEdition')->create(\%publ);
	}

    }

    #if ($b =~ m/^(\\[res]bibitem\{\w+?\})/ ) {
    if ($b =~ m/(^\\[res]bibitemrp\{\w+?\})/ ) {
	if ($match == 0) {
	   print "No match: $1\n";
	}
    }
}

