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

my $script_name = 'bacteria_rna_seq_expression';

my %scripts_and_expected_files = (
    '-t study -i "ZZZ" -r "ABC"' => [
        'command_line.log',                             'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',        'prokaryotes/mapping/mapping__ZZZABC_smalt.conf',
        'prokaryotes/prokaryotes.ilm.studies',          'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',     'prokaryotes/prokaryotes_rna_seq_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf', 'prokaryotes/qc/qc__ZZZ.conf',
        'prokaryotes/rna_seq/rna_seq__ZZZABC.conf',     'prokaryotes/stored/stored_global.conf'
    ],
    '-t lane -i 1234_5#6 -r "ABC"' => [
        'command_line.log',                               'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',          'prokaryotes/mapping/mapping__1234_5_6ABC_smalt.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf', 'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',  'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_rna_seq_pipeline.conf',  'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__1234_5_6.conf',               'prokaryotes/rna_seq/rna_seq__1234_5_6ABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t library -i "libname" -r "ABC"' => [
        'command_line.log',                               'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',          'prokaryotes/mapping/mapping__libnameABC_smalt.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf', 'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',  'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_rna_seq_pipeline.conf',  'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__libname.conf',                'prokaryotes/rna_seq/rna_seq__libnameABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t sample -i "sample" -r "ABC"' => [
        'command_line.log',                               'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',          'prokaryotes/mapping/mapping__sampleABC_smalt.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf', 'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',  'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_rna_seq_pipeline.conf',  'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__sample.conf',                 'prokaryotes/rna_seq/rna_seq__sampleABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t file -i "t/data/lanes_file" -r "ABC"' => [
        'command_line.log',
        'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',
        'prokaryotes/mapping/mapping__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC_smalt.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_rna_seq_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name.conf',
        'prokaryotes/rna_seq/rna_seq__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -s "StandardProtocol"' => [
        'command_line.log',
        'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',
        'prokaryotes/mapping/mapping__ZZZ_StandardProtocolABC_smalt.conf',
        'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_rna_seq_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__ZZZ_StandardProtocol.conf',
        'prokaryotes/rna_seq/rna_seq__ZZZ_StandardProtocolABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -s "Staphylococcus aureus"' => [
        'command_line.log',
        'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',
        'prokaryotes/mapping/mapping__ZZZ_Staphylococcus_aureusABC_smalt.conf',
        'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_rna_seq_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__ZZZ_Staphylococcus_aureus.conf',
        'prokaryotes/rna_seq/rna_seq__ZZZ_Staphylococcus_aureusABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m bwa' => [
        'command_line.log',                             'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',        'prokaryotes/mapping/mapping__ZZZABC_bwa.conf',
        'prokaryotes/prokaryotes.ilm.studies',          'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',     'prokaryotes/prokaryotes_rna_seq_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf', 'prokaryotes/qc/qc__ZZZ.conf',
        'prokaryotes/rna_seq/rna_seq__ZZZABC.conf',     'prokaryotes/stored/stored_global.conf'
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
