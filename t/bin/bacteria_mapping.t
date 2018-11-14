#!/usr/bin/env perl
package Bio::VertRes::Config::Tests;
use Moose;
use Data::Dumper;
use File::Temp;

use File::Find;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

my $script_name = 'Bio::VertRes::Config::CommandLine::BacteriaMapping';

my %scripts_and_expected_files = (
    '-a ABC'                 => ['command_line.log'],
    '-t study -i ZZZ -r ABC' => [
        'command_line.log',                                  'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_ZZZ_ABC_smalt.conf',    'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf', 
        'prokaryotes/permissions/permissions_ZZZ.conf',      'prokaryotes/prokaryotes_permissions_pipeline.conf',
    ],
    '-t lane -i 1234_5#6 -r ABC' => [
        'command_line.log',                                    'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_1234_5_6_ABC_smalt.conf', 'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',       
        'prokaryotes/prokaryotes_permissions_pipeline.conf',   
    ],
    '-t library -i libname -r ABC' => [
        'command_line.log',                                   'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_libname_ABC_smalt.conf', 'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',      
        'prokaryotes/prokaryotes_permissions_pipeline.conf',  
    ],
    '-t sample -i sample -r ABC' => [
        'command_line.log',                                  'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_sample_ABC_smalt.conf', 'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',     
        'prokaryotes/prokaryotes_permissions_pipeline.conf',
    ],
    '-t file -i t/data/lanes_file -r ABC' => [
        'command_line.log',
        'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name_ABC_smalt.conf',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf',
    ],
    '-t study -i ZZZ -r ABC -p StandardProtocol' => [
        'command_line.log',                                  'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_ZZZ_ABC_smalt.conf',    'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf',
        'prokaryotes/permissions/permissions_ZZZ.conf',      
    ],
    '-t study -i ZZZ -r ABC -s "Staphylococcus_aureus"' => [
        'command_line.log',                                                     'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_ZZZ_Staphylococcus_aureus_ABC_smalt.conf', 'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf',                    'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf',
        'prokaryotes/permissions/permissions_ZZZ.conf',   
    ],
    '-t study -i ZZZ -r ABC -m bwa' => [
        'command_line.log',                                  'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_ZZZ_ABC_bwa.conf',      'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf',
        'prokaryotes/permissions/permissions_ZZZ.conf',      
    ],
    '-t study -i ZZZ -r ABC -m stampy' => [
        'command_line.log',                                  'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_ZZZ_ABC_stampy.conf',   'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf', 
        'prokaryotes/permissions/permissions_ZZZ.conf',      
    ],
    '-t study -i ZZZ -r ABC -m ssaha2' => [
        'command_line.log',
        'prokaryotes/import_cram/import_cram_global.conf', 'prokaryotes/mapping/mapping_ZZZ_ABC_ssaha.conf',
        'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf',
        'prokaryotes/permissions/permissions_ZZZ.conf',
    ],
    '-t study -i ZZZ -r ABC -m tophat' => [
        'command_line.log',                                  'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_ZZZ_ABC_tophat.conf',   'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',  
        'prokaryotes/prokaryotes_permissions_pipeline.conf', 'prokaryotes/permissions/permissions_ZZZ.conf',
    ],
    '-t study -i ZZZ -r ABC -m bowtie2' => [
        'command_line.log',                                  'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/mapping/mapping_ZZZ_ABC_bowtie2.conf',  'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf', 'prokaryotes/permissions/permissions_ZZZ.conf',
    ],

);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
