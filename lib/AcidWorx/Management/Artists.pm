package AcidWorx::Management::Artists;

use v5.20;
use Moose;

use Carp;
use Data::Dumper qw( Dumper );

with 'AcidWorx';

has 'new_request' => ( is => 'rw', isa => 'Maybe[ArrayRef]' );
has 'artists' => ( is => 'rw', isa => 'Maybe[ArrayRef]' );

sub BUILD {
	my $self = shift;
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
	
	$self->new_request( undef );

	my $sql =qq~SELECT * FROM artist WHERE signed = 0~;
	my $new_request = $self->dbh->selectall_hashref( $sql, 'artist_id')
		or confess "Failed to fetch new artist requests: " . $self->dbh->errstr;

	if ( keys %$new_request ) {
		$self->new_request( [map { $new_request->{$_} } keys %$new_request] );
	}
}

sub get_artists {
	my $self = shift;
	
	$self->artists( undef );

	my $sql =qq~SELECT artist_id, artist_name FROM artist WHERE signed = 1~;
	my $artists_aref = $self->dbh->selectall_arrayref( $sql )
		or confess "Failed to fetch new artist requests: " . $self->dbh->errstr;

	my @artists;

	foreach ( @$artists_aref ) {
		push @artists, { 
			id => $_->[0], 
			name => $_->[1] 
		};
	}

	$self->artists( \@artists );

}

1;