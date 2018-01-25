package Bio::VertRes::Config::CommandLine::EukaryotesAssembly;

# ABSTRACT: Create assembly files

=head1 SYNOPSIS

Create assembly files, but QC must have been run first, avoids the need for a reference

=cut

use Moose;
use Bio::VertRes::Config::Recipes::EukaryotesAssembly;
extends 'Bio::VertRes::Config::CommandLine::Common';

has 'database'  => ( is => 'rw', isa => 'Str', default => 'pathogen_euk_track' );

sub run {
    my ($self) = @_;

    ($self->type && $self->id  && !$self->help ) or die $self->usage_text;

    my %mapping_parameters = %{$self->mapping_parameters};
    $mapping_parameters{'assembler'} = $self->assembler if defined ($self->assembler);
    $mapping_parameters{'iva_qc'} = $self->iva_qc if defined ($self->iva_qc);
    $mapping_parameters{'kraken_db'} = $self->kraken_db if defined ($self->kraken_db);
    Bio::VertRes::Config::Recipes::EukaryotesAssembly->new( \%mapping_parameters )->create();

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
Usage: eukaryote_assembly -t <ID type> -i <ID>  [options]
Pipeline to run assembly and annotation. Study must be registered and QC'd separately first

Required: 
  -t            STR Type (study/lane/file)
  -i            STR Study name, study ID, lane, file of lanes
      
Options:
  -s            STR Limit to a single species name (e.g. 'Leishmania donovani')     
  --assembler   STR Set a different assembler (spades/velvet) [velvet]
  -d            STR Specify a database [pathogen_euk_track]
  -c            STR Base directory to config files [/nfs/pathnfs05/conf]
  --root        STR Base directory for the pipelines [/lustre/scratch118/infgen/pathogen/pathpipe]
  --log         STR Base directory for the log files [/nfs/pathnfs05/log]
  --db_file     STR Filename containing database connection details [/software/pathogen/config/database_connection_details]
  -a            STR Search for available reference matching pattern and exit.  
  -h                Print this message and exit
  
NOTE - If the data you are regestering is external you need to add the -d pathogen_euk_external option to the command.

NOTE - If you are uncertain that your request was successful, please do NOT run the command again. Instead, please direct any queries to path-help\@sanger.ac.uk.

If you use the results of this pipeline, please acknowledge the pathogen informatics team and include the appropriate citation. For more information on how to cite this pipeline, please see:
http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Pipelines_-_Methods

For example usage and more information about the assembly pipeline, please see:
http://mediawiki.internal.sanger.ac.uk/index.php/Assembly_Pipeline_-_Pathogen_Informatics

USAGE
};



__PACKAGE__->meta->make_immutable;
no Moose;
1;
