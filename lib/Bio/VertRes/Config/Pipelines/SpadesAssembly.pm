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
has 'prefix'               => ( is => 'ro', isa => 'Bio::VertRes::Config::Prefix', default => '_spades_' );
has '_assembler_exec'      => ( is => 'ro', isa => 'Str',  default => '/software/pathogen/external/apps/usr/bin/spades-3.9.0.py' );
has '_optimiser_exec'      => ( is => 'ro', isa => 'Str',  default => '/software/pathogen/external/apps/usr/bin/spades-3.9.0.py' );
has '_max_threads'         => ( is => 'ro', isa => 'Int',  default => 2 );
has '_single_cell'         => ( is => 'ro', isa => 'Bool', default => 0 );
has '_spades_opts'         => ( is => 'ro', isa => 'Maybe[Str]',  default => undef );

has '_pipeline_version'    => ( is => 'rw', isa => 'Str',  lazy_build => 1 );
has '_flag'                => ( is => 'ro', isa => 'Str',  lazy_build => 1 );

sub _build__flag {
    my $self = shift;

    my $flag = $self->_error_correct . 
               $self->_normalise .
               $self->_remove_primers .
               $self->_improve_assembly;
    return $flag;
}

sub _build__pipeline_version {
    my $self = shift;
    my %subversions = %{ $self->_subversions };

    my $version = '3' . $subversions{$self->_flag};
    $self->_pipeline_version($version);
}

override 'to_hash' => sub {
    my ($self) = @_;

    my $output_hash = super();

    $output_hash->{data}{single_cell}      = $self->_single_cell;
    $output_hash->{data}{pipeline_version} = $self->_pipeline_version;
    if(defined($self->_spades_opts))
    {
    	$output_hash->{data}{spades_opts} = $self->_spades_opts;
    }

    return $output_hash;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
