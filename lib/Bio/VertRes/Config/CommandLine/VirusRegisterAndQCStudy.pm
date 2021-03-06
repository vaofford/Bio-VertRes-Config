package Bio::VertRes::Config::CommandLine::VirusRegisterAndQCStudy;

# ABSTRACT: Create config scripts to register and QC virus

=head1 SYNOPSIS

Create config scripts to register and QC virus

=cut

use Moose;
use Bio::VertRes::Config::Recipes::VirusRegisterAndQCStudy;
with 'Bio::VertRes::Config::CommandLine::ReferenceHandlingRole';
extends 'Bio::VertRes::Config::CommandLine::Common';

has 'database'  => ( is => 'rw', isa => 'Str', default => 'pathogen_virus_track' );

sub run {
    my ($self) = @_;

    ( ( ( defined($self->available_references) && $self->available_references ne "" ) || ( $self->reference && $self->type && $self->id ) )
          && !$self->help ) or die $self->usage_text;

    return if(handle_reference_inputs_or_exit( $self->reference_lookup_file, $self->available_references, $self->reference ) == 1);

    my %mapping_parameters = %{$self->mapping_parameters};
    $mapping_parameters{'assembler'} = $self->assembler if defined ($self->assembler);
    Bio::VertRes::Config::Recipes::VirusRegisterAndQCStudy->new( \%mapping_parameters )->create();

    $self->retrieving_results_text;
};

sub retrieving_results_text {
    my ($self) = @_;
    $self->retrieving_register_and_qc_results_text;
}

sub usage_text
{
  my ($self) = @_;
  $self->register_and_qc_usage_text;
}

sub register_and_qc_usage_text {
    my ($self) = @_;
    return <<USAGE;
Usage: virus_register_and_qc_study -t <ID type> -i <ID> -r <reference> [options]
Pipeline to register and QC a virus study.

Required:
  -t            STR Type (study/lane/file)
  -i            STR Study name, study ID, lane, file of lanes
  -r            STR Reference to map against. Must match exactly one of the references from the -a option.

Options:
  -s            STR Limit to a single species name (e.g. 'Influenzavirus A')
  -d            STR Specify a database [pathogen_virus_track]
  -c            STR Base directory to config files [/nfs/pathnfs05/conf]
  --root        STR Base directory for the pipelines [/lustre/scratch118/infgen/pathogen/pathpipe]
  --log         STR Base directory for the log files [/nfs/pathnfs05/log]
  --db_file     STR Filename containing database connection details [/software/pathogen/config/database_connection_details]
  -a            STR Search for available reference matching pattern and exit.
  -h                Print this message and exit

NOTE - If the data you are regestering is external you need to add the -d pathogen_virus_external option to the command.

NOTE - If you are uncertain that your request was successful, please do NOT run the command again. Instead, please direct any queries to path-help\@sanger.ac.uk.

If you use the results of this pipeline, please acknowledge the pathogen informatics team and include the appropriate citation. For more information on how to cite this pipeline, please see:
http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Pipelines_-_Methods

For more information about the QC and assembly pipeline, please see:
http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Pipelines#QC_Pipeline

USAGE
};



__PACKAGE__->meta->make_immutable;
no Moose;
1;
