package Bio::VertRes::Config::Recipes::PacbioRegister;
# ABSTRACT: Register a pacbio study (i.e. creates assembly and annotation config files)

=head1 SYNOPSIS

Register a pacbio study
   use Bio::VertRes::Config::Recipes::PacbioRegister;

   my $obj = Bio::VertRes::Config::Recipes::PacbioRegister->new(
     database => 'abc',
     limits => {project => ['Study ABC']},
     reference => 'ABC',
     reference_lookup_file => '/path/to/refs.index');
   $obj->create;

=cut

use Moose;
use Bio::VertRes::Config::RegisterStudy;
extends 'Bio::VertRes::Config::Recipes::Common';
with 'Bio::VertRes::Config::Recipes::Roles::PacbioRegisterStudy';
#with 'Bio::VertRes::Config::Recipes::Roles::Reference';
with 'Bio::VertRes::Config::Recipes::Roles::CreateGlobal';

has 'assembler'                   => ( is => 'ro', isa => 'Str',  default => 'pacbio' );
has 'no_ass'                      => ( is => 'ro', isa => 'Bool', default => 0 );
has '_pipeline_version'           => ( is => 'ro', isa => 'Str' );
has '_kingdom'                    => ( is => 'ro', isa => 'Str',  default => "Bacteria" );
has '_vrtrack_processed_flags'    => ( is => 'ro', isa => 'HashRef', default => sub {{ assembled => 0, stored => 1}} );
has '_max_threads'         => ( is => 'ro', isa => 'Int',  default => 16 );
has '_queue'			   => ( is => 'ro', isa => 'Str', default => 'normal');
has '_genome_size'         => ( is => 'ro', isa => 'Int', default => 3000000 );
has '_memory'         	   => ( is => 'ro', isa => 'Int', default => 100000 ); # for assembly bsub job
has '_memory_in_mb'		   => ( is => 'ro', isa => 'Int', default => 4000 ); # for annotation
has '_target_coverage'	   => ( is => 'ro', isa => 'Int', default => 30 );
has '_no_bsub'			   => ( is => 'ro', isa => 'Bool', default => 1 );
has 'circularise'		   => ( is => 'ro', isa => 'Bool', default => 0 );


override '_pipeline_configs' => sub {
    my ($self) = @_;
    my @pipeline_configs;
   
    if($self->assembler eq 'hgap')
    {
        $self->add_hgap_assembly_config(\@pipeline_configs);
    }
 
    $self->add_bacteria_annotate_config(\@pipeline_configs);

    return \@pipeline_configs;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

