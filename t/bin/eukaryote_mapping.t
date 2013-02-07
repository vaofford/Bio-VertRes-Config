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

my $script_name = 'eukaryote_mapping';

my %scripts_and_expected_files = (
    '-a "ABC" '                  => ['command_line.log'],
    '-t study -i "ZZZ" -r "ABC"' => [
        'command_line.log',                           'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',       'eukaryotes/mapping/mapping__ZZZABC_smalt.conf',
        'eukaryotes/eukaryotes.ilm.studies',          'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf', 'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',     'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/qc/qc__ZZZ.conf',                 'eukaryotes/stored/stored_global.conf'
    ],
    '-t lane -i 1234_5#6 -r "ABC"' => [
        'command_line.log',                             'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',         'eukaryotes/mapping/mapping__1234_5_6ABC_smalt.conf',
        'eukaryotes/eukaryotes_assembly_pipeline.conf', 'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',  'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_stored_pipeline.conf',   'eukaryotes/qc/qc__1234_5_6.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t library -i "libname" -r "ABC"' => [
        'command_line.log',                             'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',         'eukaryotes/mapping/mapping__libnameABC_smalt.conf',
        'eukaryotes/eukaryotes_assembly_pipeline.conf', 'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',  'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_stored_pipeline.conf',   'eukaryotes/qc/qc__libname.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t sample -i "sample" -r "ABC"' => [
        'command_line.log',                             'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',         'eukaryotes/mapping/mapping__sampleABC_smalt.conf',
        'eukaryotes/eukaryotes_assembly_pipeline.conf', 'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',  'eukaryotes/eukaryotes_qc_pipeline.conf',
        'eukaryotes/eukaryotes_stored_pipeline.conf',   'eukaryotes/qc/qc__sample.conf',
        'eukaryotes/stored/stored_global.conf'
    ],
    '-t file -i "t/data/lanes_file" -r "ABC"' => [
        'command_line.log',
        'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',
        'eukaryotes/mapping/mapping__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC_smalt.conf',
        'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',

        'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/qc/qc__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name.conf',

        'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -p "StandardProtocol"' => [
        'command_line.log',                           'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',       'eukaryotes/mapping/mapping__ZZZABC_smalt.conf',
        'eukaryotes/eukaryotes.ilm.studies',          'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf', 'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',     'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/qc/qc__ZZZ.conf',                 'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -s "Staphylococcus aureus"' => [
        'command_line.log',
        'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',
        'eukaryotes/mapping/mapping__ZZZ_Staphylococcus_aureusABC_smalt.conf',
        'eukaryotes/eukaryotes.ilm.studies',
        'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf',
        'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',

        'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/qc/qc__ZZZ_Staphylococcus_aureus.conf',

        'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m bwa' => [
        'command_line.log',                           'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',       'eukaryotes/mapping/mapping__ZZZABC_bwa.conf',
        'eukaryotes/eukaryotes.ilm.studies',          'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf', 'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',     'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/qc/qc__ZZZ.conf',                 'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m stampy' => [
        'command_line.log',                           'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',       'eukaryotes/mapping/mapping__ZZZABC_stampy.conf',
        'eukaryotes/eukaryotes.ilm.studies',          'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf', 'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',     'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/qc/qc__ZZZ.conf',                 'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m ssaha2' => [
        'command_line.log',                           'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',       'eukaryotes/mapping/mapping__ZZZABC_ssaha2.conf',
        'eukaryotes/eukaryotes.ilm.studies',          'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf', 'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',     'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/qc/qc__ZZZ.conf',                 'eukaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m tophat' => [
        'command_line.log',                           'eukaryotes/assembly/assembly_global.conf',
        'eukaryotes/import/import_global.conf',       'eukaryotes/mapping/mapping__ZZZABC_tophat.conf',
        'eukaryotes/eukaryotes.ilm.studies',          'eukaryotes/eukaryotes_assembly_pipeline.conf',
        'eukaryotes/eukaryotes_import_pipeline.conf', 'eukaryotes/eukaryotes_mapping_pipeline.conf',
        'eukaryotes/eukaryotes_qc_pipeline.conf',     'eukaryotes/eukaryotes_stored_pipeline.conf',
        'eukaryotes/qc/qc__ZZZ.conf',                 'eukaryotes/stored/stored_global.conf'
    ],

);

execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
