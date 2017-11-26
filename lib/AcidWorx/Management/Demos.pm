package AcidWorx::Management::Demos;

use v5.20;
use Moose;
use Carp;

use Data::Dumper qw( Dumper );

with 'AcidWorx';

has 'all_demos' => ( 'is' => 'rw', 'isa' => 'Maybe[ArrayRef]' );
has 'dont_populate' => ( 'is' => 'rw', 'isa' => 'Bool' );

sub BUILD {
	my $self = shift;
	$self->populate unless $self->dont_populate;
}

sub populate {
	my $self = shift;

	$self->all_demos( undef );

	my $sql = qq~
		SELECT * FROM demo WHERE approved = 0
	~;

	my $demos = $self->dbh->selectall_hashref( $sql, 'id' );

	warn Dumper $demos;

	if ( keys %$demos ) { 
		my $demos_aref = [];
		push @$demos_aref, map {$demos->{$_}} keys %$demos;

		$self->all_demos( $demos_aref );
	}

}

sub set_approval {
	my ( $self, $token, $approval_status ) = @_;
	my $sql = qq~
		UPDATE demo SET approved = ? WHERE token = ?
	~;

	$self->dbh->do( $sql, {}, $approval_status, $token ) 
		or confess "Failed to update demo: " . $self->dbh->errstr;

}
1;
