package Bio::VertRes::Config::Pipelines::IvaAssembly;

# ABSTRACT: A base class for generating an Assembly pipeline config file using IVA

=head1 SYNOPSIS

A class for generating the Assembly pipeline config file using the velvet assembler
   use Bio::VertRes::Config::Pipelines::IvaAssembly;
   
   my $pipeline = Bio::VertRes::Config::Pipelines::IvaAssembly->new(database    => 'abc'
                                                                       config_base => '/path/to/config/base',
                                                                       limits      => { project => ['project name']);
   $pipeline->to_hash();

=cut


use Moose;
extends 'Bio::VertRes::Config::Pipelines::Assembly';

has '_assembler'           => ( is => 'ro', isa => 'Str',  default => 'iva' );
has '_assembler_exec'      => ( is => 'ro', isa => 'Str',  default => '/software/pathogen/external/bin/iva' );
has '_optimiser_exec'      => ( is => 'ro', isa => 'Str',  default => '/software/pathogen/external/bin/iva' );
has 'prefix'               => ( is => 'ro', isa => 'Bio::VertRes::Config::Prefix', default => '_iva_' );
has '_max_threads'         => ( is => 'ro', isa => 'Int',  default => 8 );
has '_trimmomatic_jar'     => ( is => 'ro', isa => 'Str',  default => '/software/pathogen/external/apps/usr/local/Trimmomatic-0.32/trimmomatic-0.32.jar' );
has '_adapters_file'       => ( is => 'ro', isa => 'Str',  default => '/lustre/scratch108/pathogen/pathpipe/usr/share/solexa-adapters.fasta' );
has '_improve_assembly'    => ( is => 'ro', isa => 'Bool', default => 0 );

override 'to_hash' => sub {
    my ($self) = @_;
    my $output_hash = super();

    $output_hash->{data}{trimmomatic_jar} = $self->_trimmomatic_jar;
    $output_hash->{data}{adapters_file} = $self->_adapters_file;
    $output_hash->{data}{improve_assembly} = $self->_improve_assembly;
    $output_hash->{data}{error_correct} = 0;
    $output_hash->{data}{normalise} = 0;
    $output_hash->{data}{remove_primers} = 0;

    return $output_hash;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
