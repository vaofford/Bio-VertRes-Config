package Bio::VertRes::Config::CommandLine::BacteriaAssemblyAndAnnotation;

# ABSTRACT: Create assembly and annotation files

=head1 SYNOPSIS

Create assembly and annotation files, but QC must have been run first, avoids the need for a reference

=cut

use Moose;
use Bio::VertRes::Config::Recipes::BacteriaAssemblyAndAnnotation;
extends 'Bio::VertRes::Config::CommandLine::Common';

has 'database'  => ( is => 'rw', isa => 'Str', default => 'pathogen_prok_track' );

sub run {
    my ($self) = @_;

    ($self->type && $self->id  && !$self->help ) or die $self->usage_text;

    my %mapping_parameters = %{$self->mapping_parameters};
    $mapping_parameters{'assembler'} = $self->assembler if defined ($self->assembler);
    $mapping_parameters{'iva_qc'} = $self->iva_qc if defined ($self->iva_qc);
    $mapping_parameters{'kraken_db'} = $self->kraken_db if defined ($self->kraken_db);
    Bio::VertRes::Config::Recipes::BacteriaAssemblyAndAnnotation->new( \%mapping_parameters )->create();

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
Usage: bacteria_assembly_and_annotation [options]
Pipeline to run assembly and annotation. Study must be registered and QC'd separately first

Required: 
  -t            STR Type (study/lane/file)
  -i            STR Study name, study ID, lane, file of lanes
	  
Options:
  -s            STR Limit to a single species name (e.g. 'Staphylococcus aureus')	 
  --assembler   STR Set a different assembler (spades/velvet/iva) [velvet]
  --spades_opts STR Modify parameters sent to SPAdes [--careful --cov-cutoff auto]
  -d            STR Specify a database [pathogen_prok_track]
  -c            STR Base directory to config files [/nfs/pathnfs05/conf]
  --root        STR Base directory for the pipelines [/lustre/scratch118/infgen/pathogen/pathpipe]
  --log         STR Base directory for the log files [/nfs/pathnfs05/log]
  --db_file     STR Filename containing database connection details [/software/pathogen/config/database_connection_details]
  -a            STR Search for available reference matching pattern and exit.  
  -h                Print this message and exit
  
# Assemble and annotate a study
bacteria_assembly_and_annotation -t study -i 1234

# Assemble with SPAdes and provide custom options
bacteria_assembly_and_annotation -t study -i 1234 --assembler spades --spades_opts '--careful -k 41,51,61'

USAGE
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;