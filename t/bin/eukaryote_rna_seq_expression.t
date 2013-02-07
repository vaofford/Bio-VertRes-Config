#!/usr/bin/env perl
package Bio::VertRes::Config::Tests;
use strict;
use warnings;
use Data::Dumper;
use File::Temp;
use File::Slurp;
use File::Find;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
}

my $script_name = 'eukaryote_rna_seq_expression';

my %scripts_and_expected_files = (
    '-t file -i "t/data/lanes_file" -r "ABC"' => [
        'command_line.log',
        'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_rna_seq_pipeline.conf',
        'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/import/import_global.conf',
        'eukaryotes/mapping/mapping__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC_tophat.conf',
        'eukaryotes/qc/qc__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name.conf',
        'eukaryotes/rna_seq/rna_seq__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t lane -i 1234_5#6 -r "ABC"' => [
        'command_line.log',                             'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/eukaryotes_assembly_pipeline.conf', 'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',  'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_rna_seq_pipeline.conf',  'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/import/import_global.conf',         'eukaryotes/mapping/mapping__1234_5_6ABC_tophat.conf',
        'eukaryotes/qc/qc__1234_5_6.conf',              'eukaryotes/rna_seq/rna_seq__1234_5_6ABC.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t library -i "libname" -r "ABC"' => [
        'command_line.log',                             'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/eukaryotes_assembly_pipeline.conf', 'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',  'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_rna_seq_pipeline.conf',  'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/import/import_global.conf',         'eukaryotes/mapping/mapping__libnameABC_tophat.conf',
        'eukaryotes/qc/qc__libname.conf',               'eukaryotes/rna_seq/rna_seq__libnameABC.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t sample -i "sample" -r "ABC"' => [
        'command_line.log',                             'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/eukaryotes_assembly_pipeline.conf', 'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',  'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_rna_seq_pipeline.conf',  'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/import/import_global.conf',         'eukaryotes/mapping/mapping__sampleABC_tophat.conf',
        'eukaryotes/qc/qc__sample.conf',                'eukaryotes/rna_seq/rna_seq__sampleABC.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -s "StrandSpecificProtocol"' => [
        'command_line.log',
        'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/eukaryotes.ilm.studies',
        'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_rna_seq_pipeline.conf',
        'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/import/import_global.conf',
        'eukaryotes/mapping/mapping__ZZZ_StrandSpecificProtocolABC_tophat.conf',
        'eukaryotes/qc/qc__ZZZ_StrandSpecificProtocol.conf',
        'eukaryotes/rna_seq/rna_seq__ZZZ_StrandSpecificProtocolABC.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -s "Staphylococcus aureus"' => [
        'command_line.log',
        'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/eukaryotes.ilm.studies',
        'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_rna_seq_pipeline.conf',
        'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/import/import_global.conf',
        'eukaryotes/mapping/mapping__ZZZ_Staphylococcus_aureusABC_tophat.conf',
        'eukaryotes/qc/qc__ZZZ_Staphylococcus_aureus.conf',
        'eukaryotes/rna_seq/rna_seq__ZZZ_Staphylococcus_aureusABC.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC"' => [
        'command_line.log',                               'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/eukaryotes.ilm.studies',              'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf',     'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',         'eukaryotes/eukaryotes_rna_seq_pipeline.conf',
        'eukaryotes/eukaryotes_stored_pipeline.conf',     'eukaryotes/import/import_global.conf',
        'eukaryotes/mapping/mapping__ZZZABC_tophat.conf', 'eukaryotes/qc/qc__ZZZ.conf',
        'eukaryotes/rna_seq/rna_seq__ZZZABC.conf',        'eukaryotes/stored/stored_global.conf'
    ],

);

our @actual_files_found;

for my $script_parameters ( sort keys %scripts_and_expected_files ) {
    my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
    my $destination_directory = $destination_directory_obj->dirname();

    my $full_script =
      './bin/' . $script_name . ' ' . $script_parameters . " -c $destination_directory -l t/data/refs.index";
    system("$full_script >/dev/null 2>&1");

    find( { wanted => \&process_file, no_chdir => 1 }, ($destination_directory) );
    my @temp_directory_stripped = map { /$destination_directory\/(.+)/ ? $1 : $_ } sort @actual_files_found;

    #print Dumper \@temp_directory_stripped;
    is_deeply(
        \@temp_directory_stripped,
        sort( $scripts_and_expected_files{$script_parameters} ),
        "files created as expected for $full_script"
    );
    @actual_files_found = ();
}

done_testing();

sub process_file {
    if ( -f $_ ) {
        push( @actual_files_found, $File::Find::name );
    }
}
