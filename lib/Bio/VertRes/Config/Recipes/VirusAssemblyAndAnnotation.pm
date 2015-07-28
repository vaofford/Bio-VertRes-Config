package Bio::VertRes::Config::Recipes::VirusAssemblyAndAnnotation;
# ABSTRACT: Create the assembly and anntation files only, so no reference required, but for it to run you need to have done QC first

=head1 SYNOPSIS

Create the assembly and anntation files only, so no reference required, but for it to run you need to have done QC first
   use Bio::VertRes::Config::Recipes::VirusAssemblyAndAnnotation;

   my $obj = Bio::VertRes::Config::Recipes::VirusAssemblyAndAnnotation->new(
     database => 'abc',
     limits => {project => ['Study ABC']});
   $obj->create;

=cut

use Moose;
extends 'Bio::VertRes::Config::Recipes::Common';
with 'Bio::VertRes::Config::Recipes::Roles::VirusRegisterStudy';

has 'assembler'            => ( is => 'ro', isa => 'Str',  default => 'spades' );
has '_error_correct'       => ( is => 'ro', isa => 'Bool', default => 1 );
has '_remove_primers'      => ( is => 'ro', isa => 'Bool', default => 1 );
has '_pipeline_version'    => ( is => 'ro', isa => 'Str' );
has '_normalise'           => ( is => 'ro', isa => 'Bool', default => 1 );
has '_kingdom'             => ( is => 'ro', isa => 'Str',  default => "Viruses" );
has '_iva_qc'			   => ( is => 'ro', isa => 'Bool', default => 1 ); # always run iva_qc for viruses
has '_kraken_db'		   => ( is => 'ro', isa => 'Str',  default => "/lustre/scratch108/pathogen/pathpipe/kraken/assemblyqc_fluhiv_20150728" );
#iva options
has '_iva_insert_size'		=> (is => 'rw', isa => 'Int',  default => 500 );
has '_iva_strand_bias'		=> (is => 'rw', isa => 'Num',  default => 0.1 );		

override '_pipeline_configs' => sub {
    my ($self) = @_;
    my @pipeline_configs;
    if($self->assembler eq 'velvet')
    {
        $self->add_virus_velvet_assembly_config(\@pipeline_configs);
    }
    elsif ($self->assembler eq 'iva')
    {
        $self->add_virus_iva_assembly_config(\@pipeline_configs);
    }
    else
    {
        $self->add_virus_spades_assembly_config(\@pipeline_configs);
    }
    $self->add_virus_annotate_config(\@pipeline_configs);

    return \@pipeline_configs;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

