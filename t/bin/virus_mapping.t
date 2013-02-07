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

my $script_name = 'virus_mapping';

my %scripts_and_expected_files = (
    '-a "ABC" '                  => ['command_line.log'],
    '-t study -i "ZZZ" -r "ABC"' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__ZZZABC_smalt.conf',
        'viruses/viruses.ilm.studies',          'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_stored_pipeline.conf',
        'viruses/qc/qc__ZZZ.conf',              'viruses/stored/stored_global.conf'
    ],
    '-t lane -i 1234_5#6 -r "ABC"' => [
        'command_line.log',                       'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',      'viruses/mapping/mapping__1234_5_6ABC_smalt.conf',
        'viruses/viruses_assembly_pipeline.conf', 'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',  'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_stored_pipeline.conf',   'viruses/qc/qc__1234_5_6.conf',
        'viruses/stored/stored_global.conf'
    ],
    '-t library -i "libname" -r "ABC"' => [
        'command_line.log',                       'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',      'viruses/mapping/mapping__libnameABC_smalt.conf',
        'viruses/viruses_assembly_pipeline.conf', 'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',  'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_stored_pipeline.conf',   'viruses/qc/qc__libname.conf',
        'viruses/stored/stored_global.conf'
    ],
    '-t sample -i "sample" -r "ABC"' => [
        'command_line.log',                       'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',      'viruses/mapping/mapping__sampleABC_smalt.conf',
        'viruses/viruses_assembly_pipeline.conf', 'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',  'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_stored_pipeline.conf',   'viruses/qc/qc__sample.conf',
        'viruses/stored/stored_global.conf'
    ],
    '-t file -i "t/data/lanes_file" -r "ABC"' => [
        'command_line.log',
        'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',
        'viruses/mapping/mapping__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC_smalt.conf',
        'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',

        'viruses/viruses_stored_pipeline.conf',
        'viruses/qc/qc__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name.conf',

        'viruses/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -p "StandardProtocol"' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__ZZZABC_smalt.conf',
        'viruses/viruses.ilm.studies',          'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_stored_pipeline.conf',
        'viruses/qc/qc__ZZZ.conf',              'viruses/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -s "Staphylococcus aureus"' => [
        'command_line.log',
        'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',
        'viruses/mapping/mapping__ZZZ_Staphylococcus_aureusABC_smalt.conf',
        'viruses/viruses.ilm.studies',
        'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',

        'viruses/viruses_stored_pipeline.conf',
        'viruses/qc/qc__ZZZ_Staphylococcus_aureus.conf',

        'viruses/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m bwa' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__ZZZABC_bwa.conf',
        'viruses/viruses.ilm.studies',          'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_stored_pipeline.conf',
        'viruses/qc/qc__ZZZ.conf',              'viruses/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m stampy' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__ZZZABC_stampy.conf',
        'viruses/viruses.ilm.studies',          'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_stored_pipeline.conf',
        'viruses/qc/qc__ZZZ.conf',              'viruses/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m ssaha2' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__ZZZABC_ssaha2.conf',
        'viruses/viruses.ilm.studies',          'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_stored_pipeline.conf',
        'viruses/qc/qc__ZZZ.conf',              'viruses/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m tophat' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__ZZZABC_tophat.conf',
        'viruses/viruses.ilm.studies',          'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_stored_pipeline.conf',
        'viruses/qc/qc__ZZZ.conf',              'viruses/stored/stored_global.conf'
    ],

);

execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
