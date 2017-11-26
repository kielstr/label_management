package AcidWorx::Management::NewRequest;

use v5.20;
use Moose;

use Carp;
use Data::Dumper qw( Dumper );

with 'AcidWorx';

has 'new_request' => ( is => 'rw', isa => 'Maybe[ArrayRef]' );

sub BUILD {
	my $self = shift;

	$self->get_new_request();
}

sub approve_by_token {
	my ( $self, $tokens ) = @_;
	my $sql = qq~
		UPDATE artist SET signed = 1 WHERE token = ?
	~;

	my $sth = $self->dbh->prepare( $sql ) 
		or confess "Failed to prepare sql ($sql): " . $self->dbh->errstr;

	if ( ref $tokens eq 'ARRAY') {
		for my $token ( @$tokens ) {
			$sth->execute( $token ) 
				or confess "Failed to update artist $token: " . $sth->errstr;
		}
	} else {
		$sth->execute( $tokens ) 
				or confess "Failed to update artist $tokens: " . $sth->errstr;
	}

	$self->get_new_request();
}

sub get_new_request {
	my $self = shift;
	my $sql =qq~SELECT * FROM artist WHERE signed = 0~;
	my $new_request = $self->dbh->selectall_hashref( $sql, 'artist_id')
		or confess "Failed to fetch new artist requests: " . $self->dbh->errstr;

	if ( keys %$new_request ) {
		$self->new_request( [map { $new_request->{$_} } keys %$new_request] );
	}
}

1;