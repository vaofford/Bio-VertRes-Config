package Bio::VertRes::Config::CommandLine::PacbioRegister;

# ABSTRACT: Create config scripts to assemble and annotate Pacbio data

=head1 SYNOPSIS

Create config scripts to assemble and annotate pacbio data

=cut

use Moose;
use Bio::VertRes::Config::Recipes::PacbioRegister;
with 'Bio::VertRes::Config::CommandLine::ReferenceHandlingRole';
extends 'Bio::VertRes::Config::CommandLine::Common';

has 'database'  => ( is => 'rw', isa => 'Str', default => 'pathogen_pacbio_track' );

sub run {
    my ($self) = @_;
    
     (($self->type && $self->id)  && !$self->help ) or die $self->usage_text;

    (!$self->help) or die $self->usage_text;

    #return if(handle_reference_inputs_or_exit( $self->reference_lookup_file, $self->available_references, $self->reference ) == 1);
    
    my %mapping_parameters = %{$self->mapping_parameters};
    $mapping_parameters{'circularise'} = $self->circularise if defined ($self->circularise);
   Bio::VertRes::Config::Recipes::PacbioRegister->new( \%mapping_parameters )->create();

    $self->retrieving_results_text;
};

sub retrieving_results_text {
    my ($self) = @_;
    "";
}

sub usage_text
{
  my ($self) = @_;
  $self->register_usage_text;
}

sub register_usage_text {
    my ($self) = @_;
    return <<USAGE;
Usage: pacbio_register_study [options]
Pipeline to register a pacbio study.

# Register a study (assemble and annotate)
pacbio_register_study -t study -i 1234 

# Dont circularise
pacbio_register_study -t study -i 1234 --no_circularise

# This help message
pacbio_register_study -h

USAGE
};



__PACKAGE__->meta->make_immutable;
no Moose;
1;