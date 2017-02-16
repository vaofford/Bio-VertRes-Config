package Bio::VertRes::Config::CommandLine::BacteriaRegisterAndQCStudy;

# ABSTRACT: Create config scripts to map helminths

=head1 SYNOPSIS

Create config scripts to map helminths

=cut

use Moose;
use Bio::VertRes::Config::Recipes::BacteriaRegisterAndQCStudy;
with 'Bio::VertRes::Config::CommandLine::ReferenceHandlingRole';
extends 'Bio::VertRes::Config::CommandLine::Common';

has 'database'  => ( is => 'rw', isa => 'Str', default => 'pathogen_prok_track' );

sub run {
    my ($self) = @_;

    ( ( ( defined($self->available_references) && $self->available_references ne "" ) || ( $self->reference && $self->type && $self->id ) )
          && !$self->help ) or die $self->usage_text;

    return if(handle_reference_inputs_or_exit( $self->reference_lookup_file, $self->available_references, $self->reference ) == 1);

    my %mapping_parameters = %{$self->mapping_parameters};
    $mapping_parameters{'assembler'} = $self->assembler if defined ($self->assembler);
    $mapping_parameters{'no_ass'} = defined($self->no_ass);
    $mapping_parameters{'iva_qc'} = $self->iva_qc if defined ($self->iva_qc);
    $mapping_parameters{'kraken_db'} = $self->kraken_db if defined ($self->kraken_db);
    Bio::VertRes::Config::Recipes::BacteriaRegisterAndQCStudy->new( \%mapping_parameters )->create();

    $self->retrieving_results_text;
};

sub retrieving_results_text {
    my ($self) = @_;
    "";
}

sub usage_text
{
  my ($self) = @_;
  $self->register_and_qc_usage_text;
}

sub register_and_qc_usage_text {
    my ($self) = @_;
    return <<USAGE;
Usage: bacteria_register_and_qc_study [options]
Pipeline to register, QC, assemble and annotate a bacteria study.

Required: 
  -t            STR Type (study/lane/file)
  -i            STR Study name, study ID, lane, file of lanes
  -r            STR Reference to QC against. Must match exactly one of the references from the -a option.
	  
Options:
  -s            STR Limit to a single species name (e.g. 'Staphylococcus aureus')	 
  --assembler   STR Set a different assembler (spades/velvet/iva) [velvet]
  --spades_opts STR Modify parameters sent to SPAdes [--careful --cov-cutoff auto]
  --no_aa           Dont assemble or annotate
  -d            STR Specify a database [pathogen_prok_track]
  -c            STR Base directory to config files [/nfs/pathnfs05/conf]
  --root        STR Base directory for the pipelines [/lustre/scratch118/infgen/pathogen/pathpipe]
  --log         STR Base directory for the log files [/nfs/pathnfs05/log]
  --db_file     STR Filename containing database connection details [/software/pathogen/config/database_connection_details]
  -a            STR Search for available reference matching pattern and exit.  
  -h                Print this message and exit

Example:
# Register a study, QC, assemble and annotate.
bacteria_register_and_qc_study -t study -i 1234 -r "Staphylococcus_aureus_subsp_aureus_EMRSA15_v1"

# Assemble with SPAdes and provide custom options
bacteria_register_and_qc_study -t study -i 1234 -r "Staphylococcus_aureus_subsp_aureus_EMRSA15_v1" --assembler spades --spades_opts '--careful'

USAGE
};



__PACKAGE__->meta->make_immutable;
no Moose;
1;