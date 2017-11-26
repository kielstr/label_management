package AcidWorx::Link;

use v5.20;
use Moose;
use Carp;

with 'AcidWorx';

has 'token' => (is => 'rw', isa => 'Maybe[Str]');
has 'link' => (is => 'rw', isa => 'Maybe[Str]');

sub add {
	my $self = shift;
	my $dbh = $self->dbh;

	my $sql = "INSERT INTO demo_links (token, link) VALUES (?, ?)";

	$dbh->do( $sql,{}, $self->token, $self->link ) or confess $dbh->errstr;
}

sub remove {
	my $self = shift;
	my $dbh = $self->dbh;

	my $sql = "DELETE FROM demo_links WHERE token = ? AND link = ?";

	$dbh->do( $sql,{}, $self->token, $self->link ) or confess $dbh->errstr;
}

1;