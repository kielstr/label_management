package AcidWorx::File;

use v5.20;
use Moose;
use Carp;

with 'AcidWorx';

has 'token' => (is => 'rw', isa => 'Maybe[Str]');
has 'filename' => (is => 'rw', isa => 'Maybe[Str]');
has 'path' => (is => 'rw', isa => 'Maybe[Str]');


sub add {
	my $self = shift;
	my $dbh = $self->dbh;

	my $sql = "INSERT INTO file_to_token_map (token, filename, path) VALUES (?, ?, ?)";

	$dbh->do( $sql,{}, $self->token, $self->filename, $self->path ) or confess $dbh->errstr;
}

sub remove {
	my $self = shift;
	my $dbh = $self->dbh;

	my $sql = "DELETE FROM file_to_token_map WHERE token = ? AND filename = ?";

	$dbh->do( $sql,{}, $self->token, $self->filename ) or confess $dbh->errstr;
}

1;