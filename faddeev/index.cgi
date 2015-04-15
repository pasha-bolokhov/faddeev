#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use lib qw(/home/site/lib);

use CGI qw/:standard/;
#use CGI::Carp qw(fatalsToBrowser);
#use Data::Dumper;   # to debug
use Bibl::Modules::Index;


my %p = map { $_ => get_data($_) } CGI::param;
my %c = map { $_ => cookie($_) } cookie();

$p{cookies} = \%c;

my $controller = Bibl::Modules::Index->new_nodb(\%p);

$controller->begin();       # i.e.: check for session
$controller->process();     
$controller->end();         # render view

exit;

sub get_data {
    my $name   = shift;
    my @values = CGI::param( $name );
    return @values > 1
        ? \@values
        : $values[0];
}
