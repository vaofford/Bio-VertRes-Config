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

my $script_name = 'bacteria_snp_calling';

my %scripts_and_expected_files = (
    '-a "ABC" '                  => ['command_line.log'],
    '-t study -i "ZZZ" -r "ABC"' => [
        'command_line.log',                             'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',        'prokaryotes/mapping/mapping__ZZZABC_smalt.conf',
        'prokaryotes/prokaryotes.ilm.studies',          'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',     'prokaryotes/prokaryotes_snps_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf', 'prokaryotes/qc/qc__ZZZ.conf',
        'prokaryotes/snps/snps__ZZZABC.conf',           'prokaryotes/stored/stored_global.conf'
    ],
    '-t lane -i 1234_5#6 -r "ABC"' => [
        'command_line.log',                               'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',          'prokaryotes/mapping/mapping__1234_5_6ABC_smalt.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf', 'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',  'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_snps_pipeline.conf',     'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__1234_5_6.conf',               'prokaryotes/snps/snps__1234_5_6ABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t library -i "libname" -r "ABC"' => [
        'command_line.log',                               'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',          'prokaryotes/mapping/mapping__libnameABC_smalt.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf', 'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',  'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_snps_pipeline.conf',     'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__libname.conf',                'prokaryotes/snps/snps__libnameABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t sample -i "sample" -r "ABC"' => [
        'command_line.log',                               'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',          'prokaryotes/mapping/mapping__sampleABC_smalt.conf',
        'prokaryotes/prokaryotes_assembly_pipeline.conf', 'prokaryotes/prokaryotes_import_pipeline.conf',
        'prokaryotes/prokaryotes_mapping_pipeline.conf',  'prokaryotes/prokaryotes_qc_pipeline.conf',
        'prokaryotes/prokaryotes_snps_pipeline.conf',     'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__sample.conf',                 'prokaryotes/snps/snps__sampleABC.conf',
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
        'prokaryotes/prokaryotes_snps_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name.conf',
        'prokaryotes/snps/snps__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -p "StandardProtocol"' => [
        'command_line.log',                             'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',        'prokaryotes/mapping/mapping__ZZZABC_smalt.conf',
        'prokaryotes/prokaryotes.ilm.studies',          'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',     'prokaryotes/prokaryotes_snps_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf', 'prokaryotes/qc/qc__ZZZ.conf',
        'prokaryotes/snps/snps__ZZZABC.conf',           'prokaryotes/stored/stored_global.conf'
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
        'prokaryotes/prokaryotes_snps_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf',
        'prokaryotes/qc/qc__ZZZ_Staphylococcus_aureus.conf',
        'prokaryotes/snps/snps__ZZZ_Staphylococcus_aureusABC.conf',
        'prokaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m bwa' => [
        'command_line.log',                             'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',        'prokaryotes/mapping/mapping__ZZZABC_bwa.conf',
        'prokaryotes/prokaryotes.ilm.studies',          'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',     'prokaryotes/prokaryotes_snps_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf', 'prokaryotes/qc/qc__ZZZ.conf',
        'prokaryotes/snps/snps__ZZZABC.conf',           'prokaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m stampy' => [
        'command_line.log',                             'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',        'prokaryotes/mapping/mapping__ZZZABC_stampy.conf',
        'prokaryotes/prokaryotes.ilm.studies',          'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',     'prokaryotes/prokaryotes_snps_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf', 'prokaryotes/qc/qc__ZZZ.conf',
        'prokaryotes/snps/snps__ZZZABC.conf',           'prokaryotes/stored/stored_global.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m ssaha2' => [
        'command_line.log',                             'prokaryotes/assembly/assembly_global.conf',
        'prokaryotes/import/import_global.conf',        'prokaryotes/mapping/mapping__ZZZABC_ssaha2.conf',
        'prokaryotes/prokaryotes.ilm.studies',          'prokaryotes/prokaryotes_assembly_pipeline.conf',
        'prokaryotes/prokaryotes_import_pipeline.conf', 'prokaryotes/prokaryotes_mapping_pipeline.conf',
        'prokaryotes/prokaryotes_qc_pipeline.conf',     'prokaryotes/prokaryotes_snps_pipeline.conf',
        'prokaryotes/prokaryotes_stored_pipeline.conf', 'prokaryotes/qc/qc__ZZZ.conf',
        'prokaryotes/snps/snps__ZZZABC.conf',           'prokaryotes/stored/stored_global.conf'
    ],

);

execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
