package Bio::VertRes::Config::Pipelines::SpadesAssembly;

# ABSTRACT: A base class for generating an Assembly pipeline config file using spades

=head1 SYNOPSIS

A class for generating the Assembly pipeline config file using the velvet assembler
   use Bio::VertRes::Config::Pipelines::SpadesAssembly;
   
   my $pipeline = Bio::VertRes::Config::Pipelines::SpadesAssembly->new(database    => 'abc'
                                                                       config_base => '/path/to/config/base',
                                                                       limits      => { project => ['project name']);
   $pipeline->to_hash();

=cut


use Moose;
extends 'Bio::VertRes::Config::Pipelines::Assembly';

has '_assembler'           => ( is => 'ro', isa => 'Str',  default => 'spades' );
has '_assembler_exec'      => ( is => 'ro', isa => 'Str',  default => '/software/pathogen/external/apps/usr/bin/spades.py' );
has '_optimiser_exec'      => ( is => 'ro', isa => 'Str',  default => '/software/pathogen/external/apps/usr/bin/spades.py' );
has '_normalise'           => ( is => 'ro', isa => 'Bool', default => 1 );
has '_max_lanes_to_search' => ( is => 'ro', isa => 'Int', default => 2000 );
has '_limit'               => ( is => 'ro', isa => 'Int', default => 500 );


override 'to_hash' => sub {
    my ($self) = @_;
    my $output_hash = super();

    $output_hash->{data}{normalise}      = $self->_normalise;

    return $output_hash;
};


__PACKAGE__->meta->make_immutable;
no Moose;
1;
