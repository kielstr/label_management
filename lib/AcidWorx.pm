package AcidWorx;

use Moose::Role;
use Carp;

has 'dbh' => ( is => 'rw' );
has 'countries' => ( is => 'rw', isa => 'ArrayRef' );


1;