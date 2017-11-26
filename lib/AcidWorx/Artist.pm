package AcidWorx::Artist;

use v5.20;

use Moose;
use Session::Token;

use Data::Dumper qw(Dumper);

extends 'AcidWorx::Utils';
with "AcidWorx";

has 'artist_id' => ( 'is' => 'rw', 'isa' => 'Int' );
has 'name' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]');
has 'artist_name' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]');
has 'address_line1' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]');
has 'address_line2' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]');
has 'address_line3' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]');
has 'country_id' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'email' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'payment_email' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'soundcloud_url' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'ra_url' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'beatport_url' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'facebook_page' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'website' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'bio' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'errors' => ( 'is' => 'rw', 'isa' => 'Maybe[ArrayRef]' );
has 'token' => ( 'is' => 'rw', 'isa' => 'Maybe[Str]' );
has 'signed' => ( 'is' => 'rw', 'isa' => 'Maybe[Int]' );
has 'email_confirmed' => ( 'is' => 'rw', 'isa' => 'Bool' );
has 'token' => ( 'is' => 'rw', 'isa'=> 'Maybe[Str]' );

my %validate_subs = (
	artist_name => \&notnull,
	real_name => \&notnull,
	address_line1 => undef,
	address_line2 => undef,
	address_line3 => undef,
	country_id => undef,
	email => \&notnull,
	payment_email => \&notnull,
	soundcloud_url => undef,
	ra_url => undef,
	beatport_url => undef,
	facebook_page => undef,
	website => undef,
	bio => undef,
);

for ( __PACKAGE__->meta->get_all_attributes() ) {
	around $_->name => sub {
	    my $orig = shift;
	    my $self = shift;

	    return $self->$orig()
	        unless @_;

	    my $value = shift;

	    if ( $validate_subs{ $value } ) {
	    	$validate_subs{ $value }->( $self, $_->name, $value );
	    }

    	return $self->$orig($value);
	};
}

sub BUILD {
	my $self = shift;
	
	if ( $self->token ) {
		$self->populate_by_token;
	} elsif ( $self->artist_id ) {
		$self->populate_by_id;
	}

	for ( __PACKAGE__->meta->get_all_attributes() ) {
		if ( $validate_subs{ $_->name } ) {
	    	$validate_subs{ $_->name}->( $self, $_->name, $self->{$_->name} );
	    }
	}

}

sub populate_by_token {
	my $self = shift;
	my $sql = qq~
		SELECT
			artist_id,
			name,
			artist_name,
			address_line1,
			address_line2,
			address_line3,
			country_id,
			email,
			payment_email,
			soundcloud_url,
			ra_url,
			beatport_url,
			facebook_page,
			website,
			bio,
			token,
			signed,
			email_confirmed
		FROM artist WHERE artist_id = ?~;
	my $artist = $self->dbh->selectrow_hashref( $sql, {}, $self->token )
		or confess "Failed to fetch new artist request: " . $self->dbh->errstr;

	for my $key ( keys %$artist ) {
		$self->$key( $artist->{ $key } );
	}

}

sub populate_by_id {
	my $self = shift;
	my $sql = qq~
		SELECT
			artist_id,
			name,
			artist_name,
			address_line1,
			address_line2,
			address_line3,
			country_id,
			email,
			payment_email,
			soundcloud_url,
			ra_url,
			beatport_url,
			facebook_page,
			website,
			bio,
			token,
			signed,
			email_confirmed
		FROM artist WHERE artist_id = ?~;
	my $artist = $self->dbh->selectrow_hashref( $sql, {}, $self->artist_id )
		or confess "Failed to fetch new artist request: " . $self->dbh->errstr;

	for my $key ( keys %$artist ) {
		$self->$key( $artist->{ $key } );
	}

}


sub notnull {
	my ( $self, $name, $value ) = @_;
	my $errors =  $self->errors;

	if ( $value and $value eq "" or not $value ) {
		$self->add_error( "$name is required" );
	}
}

sub error {
	my $self = shift;
	return ($self->errors and int @{ $self->errors }) ? 1 : 0;
}

sub add_error {
    my ( $self, $errstr ) = @_;

    my $current_errors = $self->errors;
    push @$current_errors, $errstr;
    $self->errors( $current_errors );
}

sub save {
	my $self = shift;

	my $dbh = $self->dbh;

	my $sql = qq~
		INSERT INTO artist (
			name,
			artist_name,
			address_line1,
			address_line2,
			address_line3,
			email,
			payment_email,
			soundcloud_url,
			ra_url,
			beatport_url,
			facebook_page,
			website,
			bio,
			country_id,
			token,
			email_confirmed

		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
		ON DUPLICATE KEY UPDATE
			name = ?,
			artist_name = ?,
			address_line1 = ?,
			address_line2 = ? ,
			address_line3 = ? ,
			email = ?,
			payment_email = ?,
			soundcloud_url = ?,
			ra_url = ?,
			beatport_url = ?,
			facebook_page = ?,
			website = ?,
			bio = ?,
			country_id = ?,
			token = ?,
			email_confirmed = ?
	~;

	$self->token( Session::Token->new(entropy => 256)->get )
		unless $self->token;

	$dbh->do( $sql, {}, 
		$self->name,
		$self->artist_name,
		$self->address_line1,
		$self->address_line2,
		$self->address_line3,
		$self->email,
		$self->payment_email,
		$self->soundcloud_url,
		$self->ra_url,
		$self->beatport_url,
		$self->facebook_page,
		$self->website,
		$self->bio,
		$self->country_id,
		$self->token,
		( $self->email_confirmed ? $self->email_confirmed : 0 ),

		$self->name,
		$self->artist_name,
		$self->address_line1,
		$self->address_line2,
		$self->address_line3,
		$self->email,
		$self->payment_email,
		$self->soundcloud_url,
		$self->ra_url,
		$self->beatport_url,
		$self->facebook_page,
		$self->website,
		$self->bio,
		$self->country_id,
		$self->token,
		( $self->email_confirmed ? $self->email_confirmed : 0 ),

	) or die $dbh->errstr;

}

after 'email_confirmed' => sub {
	my ( $self, $value, $save ) = @_;

	return unless $save;

	my $sql = qq~
		UPDATE artist SET email_confirmed = ? WHERE token = ? 
	~;

	warn "Updating email_confirmed to $value for token " . $self->token;

	$self->dbh->do( $sql, {}, $value, $self->token )
		or confess "Failed to set email_confirmed: " . $self->dbh->errstr;
};

__PACKAGE__->meta->make_immutable;

1;