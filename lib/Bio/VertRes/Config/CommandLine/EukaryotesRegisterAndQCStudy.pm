package Bio::VertRes::Config::CommandLine::EukaryotesRegisterAndQCStudy;

# ABSTRACT: Create config scripts to map helminths

=head1 SYNOPSIS

Create config scripts to map helminths

=cut

use Moose;
extends 'Bio::VertRes::Config::CommandLine::RegisterAndQCStudy';

has 'database'    => ( is => 'rw', isa => 'Str', default => 'pathogen_euk_track' );

override 'register_and_qc_usage_text' => sub {
    my ($self) = @_;
    return <<USAGE;
Usage: eukaryote_register_and_qc_study [options]
Pipeline to map and SNP call bacteria, producing a pseudo genome at the end.

# Search for an available reference
register_and_qc_study -a "Stap"

# Register and QC a study
register_and_qc_study -d pathogen_test_track -t study -i 1234 -r "Staphylococcus_aureus_subsp_aureus_EMRSA15_v1"

# Register and QC a single lane
register_and_qc_study -d pathogen_test_track -t lane -i 1234_5#6 -r "Staphylococcus_aureus_subsp_aureus_EMRSA15_v1"

# Register and QC a file of lanes
register_and_qc_study -d pathogen_test_track -t file -i file_of_lanes -r "Staphylococcus_aureus_subsp_aureus_EMRSA15_v1"

# Register and QC a single species in a study
register_and_qc_study -d pathogen_test_track -t study -i 1234 -r "Staphylococcus_aureus_subsp_aureus_EMRSA15_v1" -s "Staphylococcus aureus"

# This help message
register_and_qc_study -h

USAGE
};



__PACKAGE__->meta->make_immutable;
no Moose;
1;