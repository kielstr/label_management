package AcidWorx::Track;

use v5.20;

use Moose;
use Session::Token;

use Data::Dumper qw(Dumper);

extends 'AcidWorx::Utils';
with "AcidWorx";

has 'track_id' => ( 'is' => 'rw', 'isa' => 'Int' );
has 'release_id' => ( 'is' => 'rw', 'isa' => 'Int' );
has 'artist_id' => ( 'is' => 'rw', 'isa' => 'Int' );
has 'name' => ( 'is' => 'rw', 'isa' => 'Str' );
has 'create_date' => ( 'is' => 'rw', 'isa' => 'Str' );

sub save {
	my $self = shift;

	my $dbh = $self->dbh;

	my $sql = qq~
		INSERT INTO artist (
			track_id,
			artist_id,
			name,
			order
		) VALUES (?, ?, ?, ? )
		ON DUPLICATE KEY UPDATE
			track_id = ?,
			artist_id = ?,
			name = ?,
			order => ?
	~;

	$self->token( Session::Token->new(entropy => 256)->get )
		unless $self->token;

	$dbh->do( $sql, {}, 
		# Insert
		$self->track_id,
		$self->artist_name,
		$self->name,
		$self->order,
		# Update
		$self->track_id,
		$self->artist_name,
		$self->name,
		$self->order,
	) or die $dbh->errstr;

}

__PACKAGE__->meta->make_immutable;

1;