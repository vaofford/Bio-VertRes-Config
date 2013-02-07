#!/usr/bin/env perl
package Bio::VertRes::Config::Tests;
use Moose;
use Data::Dumper;
use File::Temp;
use File::Slurp;
use File::Find;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

my $script_name = 'helminth_rna_seq_expression';

my %scripts_and_expected_files = (
    '-t file -i "t/data/lanes_file" -r "ABC"' => [
        'command_line.log',
        'helminths/assembly/assembly_global.conf',
        'helminths/helminths_assembly_pipeline.conf',
        'helminths/helminths_import_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_qc_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',
        'helminths/helminths_stored_pipeline.conf',
        'helminths/import/import_global.conf',
        'helminths/mapping/mapping__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC_tophat.conf',
        'helminths/qc/qc__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name.conf',
        'helminths/rna_seq/rna_seq__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC.conf',
        'helminths/stored/stored_global.conf'
    ],
    '-t lane -i 1234_5#6 -r "ABC"' => [
        'command_line.log',                           'helminths/assembly/assembly_global.conf',
        'helminths/helminths_assembly_pipeline.conf', 'helminths/helminths_import_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',  'helminths/helminths_qc_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',  'helminths/helminths_stored_pipeline.conf',
        'helminths/import/import_global.conf',        'helminths/mapping/mapping__1234_5_6ABC_tophat.conf',
        'helminths/qc/qc__1234_5_6.conf',             'helminths/rna_seq/rna_seq__1234_5_6ABC.conf',
        'helminths/stored/stored_global.conf'
    ],
    '-t library -i "libname" -r "ABC"' => [
        'command_line.log',                           'helminths/assembly/assembly_global.conf',
        'helminths/helminths_assembly_pipeline.conf', 'helminths/helminths_import_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',  'helminths/helminths_qc_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',  'helminths/helminths_stored_pipeline.conf',
        'helminths/import/import_global.conf',        'helminths/mapping/mapping__libnameABC_tophat.conf',
        'helminths/qc/qc__libname.conf',              'helminths/rna_seq/rna_seq__libnameABC.conf',
        'helminths/stored/stored_global.conf'
    ],
    '-t sample -i "sample" -r "ABC"' => [
        'command_line.log',                           'helminths/assembly/assembly_global.conf',
        'helminths/helminths_assembly_pipeline.conf', 'helminths/helminths_import_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',  'helminths/helminths_qc_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',  'helminths/helminths_stored_pipeline.conf',
        'helminths/import/import_global.conf',        'helminths/mapping/mapping__sampleABC_tophat.conf',
        'helminths/qc/qc__sample.conf',               'helminths/rna_seq/rna_seq__sampleABC.conf',
        'helminths/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -p "StrandSpecificProtocol"' => [
        'command_line.log',                              'helminths/assembly/assembly_global.conf',
        'helminths/helminths.ilm.studies',               'helminths/helminths_assembly_pipeline.conf',
        'helminths/helminths_import_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_qc_pipeline.conf',          'helminths/helminths_rna_seq_pipeline.conf',
        'helminths/helminths_stored_pipeline.conf',      'helminths/import/import_global.conf',
        'helminths/mapping/mapping__ZZZABC_tophat.conf', 'helminths/qc/qc__ZZZ.conf',
        'helminths/rna_seq/rna_seq__ZZZABC.conf',        'helminths/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -s "Staphylococcus aureus"' => [
        'command_line.log',
        'helminths/assembly/assembly_global.conf',
        'helminths/helminths.ilm.studies',
        'helminths/helminths_assembly_pipeline.conf',
        'helminths/helminths_import_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_qc_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',
        'helminths/helminths_stored_pipeline.conf',
        'helminths/import/import_global.conf',
        'helminths/mapping/mapping__ZZZ_Staphylococcus_aureusABC_tophat.conf',
        'helminths/qc/qc__ZZZ_Staphylococcus_aureus.conf',
        'helminths/rna_seq/rna_seq__ZZZ_Staphylococcus_aureusABC.conf',
        'helminths/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC"' => [
        'command_line.log',                              'helminths/assembly/assembly_global.conf',
        'helminths/helminths.ilm.studies',               'helminths/helminths_assembly_pipeline.conf',
        'helminths/helminths_import_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_qc_pipeline.conf',          'helminths/helminths_rna_seq_pipeline.conf',
        'helminths/helminths_stored_pipeline.conf',      'helminths/import/import_global.conf',
        'helminths/mapping/mapping__ZZZABC_tophat.conf', 'helminths/qc/qc__ZZZ.conf',
        'helminths/rna_seq/rna_seq__ZZZABC.conf',        'helminths/stored/stored_global.conf'
    ],
    '-a "ABC" ' => ['command_line.log'],

);

execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();

