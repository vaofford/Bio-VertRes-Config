package Bio::VertRes::Config::CommandLine::HelminthRegisterAndQCStudy;

# ABSTRACT: Create config scripts to map helminths

=head1 SYNOPSIS

Create config scripts to map helminths

=cut

use Moose;
use Bio::VertRes::Config::Recipes::HelminthRegisterAndQCStudy;
with 'Bio::VertRes::Config::CommandLine::ReferenceHandlingRole';
extends 'Bio::VertRes::Config::CommandLine::RegisterAndQCStudy';

has 'database'    => ( is => 'rw', isa => 'Str', default => 'pathogen_helminth_track' );

override 'register_and_qc_usage_text' => sub {
    my ($self) = @_;
    return <<USAGE;
Usage: helminth_register_and_qc_study [options]
Pipeline to register and QC a helminth study.

# Search for an available reference
helminth_register_and_qc_study -a "Caenorhabditis"

# Register and QC a study
helminth_register_and_qc_study -t study -i 1234 -r "Caenorhabditis_elegans_WS226"

# Register and QC a single lane
helminth_register_and_qc_study -t lane -i 1234_5#6 -r "Caenorhabditis_elegans_WS226"

# Register and QC a file of lanes
helminth_register_and_qc_study -t file -i file_of_lanes -r "Caenorhabditis_elegans_WS226"

# Register and QC a single species in a study
helminth_register_and_qc_study -t study -i 1234 -r "Caenorhabditis_elegans_WS226" -s "Caenorhabditis elegans"

# This help message
helminth_register_and_qc_study -h

USAGE
};


__PACKAGE__->meta->make_immutable;
no Moose;
1;