package AcidWorx::Mangement::Release;

use Moose;
use v5.20;

use Data::Dumper qw( Dumper );

has 'release_id' => ( 'is' => 'rw', 'isa' => 'Int' );
has 'artists_id' => ( 'is' => 'rw', 'isa' => 'Int' );
has 'release_number' => ( 'is' => 'rw', 'isa' => 'Int' );
has 'name' => ( 'is' => 'rw', 'isa' => 'Str' );
has 'release_date' => ( 'is' => 'rw' );
has 'format' => ( 'is' => 'rw', 'Int' );
has 'description' => ( 'is' => 'rw', 'isa' => 'Str' );
has 'image' => ( 'is' => 'rw', 'isa' => 'Str' );
has 'created_date' => ( 'is' => 'rw', 'isa' => 'Str' );


1;