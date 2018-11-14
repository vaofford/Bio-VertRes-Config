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

my $script_name = 'Bio::VertRes::Config::CommandLine::BacteriaRegisterAndQCStudy';

my %scripts_and_expected_files = (
    '-a ABC '                                      => ['command_line.log'],
    '-d some_other_db_name -t study -i ZZZ -r ABC' => [
        'command_line.log',
        'some_other_db_name/annotate_assembly/annotate_assembly_ZZZ_velvet.conf',
        'some_other_db_name/assembly/assembly_ZZZ_velvet.conf',
        'some_other_db_name/import_cram/import_cram_global.conf',
        'some_other_db_name/permissions/permissions_ZZZ.conf',
        'some_other_db_name/qc/qc_ZZZ.conf',
        'some_other_db_name/some_other_db_name.ilm.studies',
        'some_other_db_name/some_other_db_name_annotate_assembly_pipeline.conf',
        'some_other_db_name/some_other_db_name_assembly_pipeline.conf',
        'some_other_db_name/some_other_db_name_import_cram_pipeline.conf',
        'some_other_db_name/some_other_db_name_permissions_pipeline.conf',
        'some_other_db_name/some_other_db_name_qc_pipeline.conf',  
    ],

    '-t file -i t/data/lanes_file -r ABC' => [
        'command_line.log',
        'prokaryotes/annotate_assembly/annotate_assembly_1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name_velvet.conf',
        'prokaryotes/assembly/assembly_1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name_velvet.conf',
        'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/prokaryotes_annotate_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/qc/qc_1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name.conf',
    ],

    '-t lane -i 1234_5#6 -r ABC' => [
        'command_line.log',                                   'prokaryotes/annotate_assembly/annotate_assembly_1234_5_6_velvet.conf',
        'prokaryotes/assembly/assembly_1234_5_6_velvet.conf', 'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/prokaryotes_annotate_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf',     'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf',  
        'prokaryotes/prokaryotes_qc_pipeline.conf',
               'prokaryotes/qc/qc_1234_5_6.conf',
    ],

    '-t library -i libname -r ABC' => [
        'command_line.log',                                  'prokaryotes/annotate_assembly/annotate_assembly_libname_velvet.conf',
        'prokaryotes/assembly/assembly_libname_velvet.conf', 'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/prokaryotes_annotate_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf',    'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf', 
        'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/qc/qc_libname.conf', 
    ],

    '-t sample -i sample -r ABC' => [
        'command_line.log',                                  'prokaryotes/annotate_assembly/annotate_assembly_sample_velvet.conf',
        'prokaryotes/assembly/assembly_sample_velvet.conf',  'prokaryotes/import_cram/import_cram_global.conf', 
        'prokaryotes/prokaryotes_annotate_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf',    'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf', 
        'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/qc/qc_sample.conf',
        
    ],

    '-t study -i ZZZ -r ABC' => [
        'command_line.log',                                        'prokaryotes/annotate_assembly/annotate_assembly_ZZZ_velvet.conf',
        'prokaryotes/assembly/assembly_ZZZ_velvet.conf',           'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/permissions/permissions_ZZZ.conf',            'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_annotate_assembly_pipeline.conf', 'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf',       'prokaryotes/prokaryotes_permissions_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',                
        'prokaryotes/qc/qc_ZZZ.conf',                              
    ],

    '-t study -i ZZZ -r ABC -assembler spades' => [
        'command_line.log',                                        'prokaryotes/annotate_assembly/annotate_assembly_ZZZ_spades.conf',
        'prokaryotes/assembly/assembly_ZZZ_spades.conf',           'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/permissions/permissions_ZZZ.conf',            'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_annotate_assembly_pipeline.conf', 'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf',       'prokaryotes/prokaryotes_permissions_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',                
        'prokaryotes/qc/qc_ZZZ.conf',                              
    ],

    '-t study -i ZZZ -r ABC -s Staphylococcus_aureus' => [
        'command_line.log',
        'prokaryotes/annotate_assembly/annotate_assembly_ZZZ_Staphylococcus_aureus_velvet.conf',
        'prokaryotes/assembly/assembly_ZZZ_Staphylococcus_aureus_velvet.conf',
        'prokaryotes/import_cram/import_cram_global.conf',
        'prokaryotes/permissions/permissions_ZZZ.conf',
        'prokaryotes/prokaryotes.ilm.studies',
        'prokaryotes/prokaryotes_annotate_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_cram_pipeline.conf',
        'prokaryotes/prokaryotes_permissions_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/qc/qc_ZZZ_Staphylococcus_aureus.conf',
        
    ],

);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
