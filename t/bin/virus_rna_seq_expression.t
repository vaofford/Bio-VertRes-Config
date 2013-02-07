#!/usr/bin/env perl
package Bio::VertRes::Config::Tests;
use Moose;
use Data::Dumper;
use File::Temp;
use File::Slurp;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

my $script_name = 'virus_rna_seq_expression';

my %scripts_and_expected_files = (
    '-t study -i "ZZZ" -r "ABC"' => [
        'command_line.log',                       'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',      'viruses/mapping/mapping__ZZZABC_smalt.conf',
        'viruses/qc/qc__ZZZ.conf',                'viruses/rna_seq/rna_seq__ZZZABC.conf',
        'viruses/stored/stored_global.conf',      'viruses/viruses.ilm.studies',
        'viruses/viruses_assembly_pipeline.conf', 'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',  'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_rna_seq_pipeline.conf',  'viruses/viruses_stored_pipeline.conf'
    ],
    '-t lane -i 1234_5#6 -r "ABC"' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__1234_5_6ABC_smalt.conf',
        'viruses/qc/qc__1234_5_6.conf',         'viruses/rna_seq/rna_seq__1234_5_6ABC.conf',
        'viruses/stored/stored_global.conf',    'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_rna_seq_pipeline.conf',
        'viruses/viruses_stored_pipeline.conf'
    ],
    '-t library -i "libname" -r "ABC"' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__libnameABC_smalt.conf',
        'viruses/qc/qc__libname.conf',          'viruses/rna_seq/rna_seq__libnameABC.conf',
        'viruses/stored/stored_global.conf',    'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_rna_seq_pipeline.conf',
        'viruses/viruses_stored_pipeline.conf'
    ],
    '-t sample -i "sample" -r "ABC"' => [
        'command_line.log',                     'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',    'viruses/mapping/mapping__sampleABC_smalt.conf',
        'viruses/qc/qc__sample.conf',           'viruses/rna_seq/rna_seq__sampleABC.conf',
        'viruses/stored/stored_global.conf',    'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf', 'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',     'viruses/viruses_rna_seq_pipeline.conf',
        'viruses/viruses_stored_pipeline.conf'
    ],
    '-t file -i "t/data/lanes_file" -r "ABC"' => [
        'command_line.log',
        'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',
        'viruses/mapping/mapping__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC_smalt.conf',
        'viruses/qc/qc__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name.conf',
        'viruses/rna_seq/rna_seq__1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_nameABC.conf',
        'viruses/stored/stored_global.conf',
        'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_rna_seq_pipeline.conf',
        'viruses/viruses_stored_pipeline.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -p "StandardProtocol"' => [
        'command_line.log',                       'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',      'viruses/mapping/mapping__ZZZABC_smalt.conf',
        'viruses/qc/qc__ZZZ.conf',                'viruses/rna_seq/rna_seq__ZZZABC.conf',
        'viruses/stored/stored_global.conf',      'viruses/viruses.ilm.studies',
        'viruses/viruses_assembly_pipeline.conf', 'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',  'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_rna_seq_pipeline.conf',  'viruses/viruses_stored_pipeline.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -s "Staphylococcus aureus"' => [
        'command_line.log',
        'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',
        'viruses/mapping/mapping__ZZZ_Staphylococcus_aureusABC_smalt.conf',
        'viruses/qc/qc__ZZZ_Staphylococcus_aureus.conf',
        'viruses/rna_seq/rna_seq__ZZZ_Staphylococcus_aureusABC.conf',
        'viruses/stored/stored_global.conf',
        'viruses/viruses.ilm.studies',
        'viruses/viruses_assembly_pipeline.conf',
        'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',
        'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_rna_seq_pipeline.conf',
        'viruses/viruses_stored_pipeline.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m bwa' => [
        'command_line.log',                       'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',      'viruses/mapping/mapping__ZZZABC_bwa.conf',
        'viruses/qc/qc__ZZZ.conf',                'viruses/rna_seq/rna_seq__ZZZABC.conf',
        'viruses/stored/stored_global.conf',      'viruses/viruses.ilm.studies',
        'viruses/viruses_assembly_pipeline.conf', 'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',  'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_rna_seq_pipeline.conf',  'viruses/viruses_stored_pipeline.conf'
    ],
    '-t study -i "ZZZ" -r "ABC" -m tophat' => [
        'command_line.log',                       'viruses/assembly/assembly_global.conf',
        'viruses/import/import_global.conf',      'viruses/mapping/mapping__ZZZABC_tophat.conf',
        'viruses/qc/qc__ZZZ.conf',                'viruses/rna_seq/rna_seq__ZZZABC.conf',
        'viruses/stored/stored_global.conf',      'viruses/viruses.ilm.studies',
        'viruses/viruses_assembly_pipeline.conf', 'viruses/viruses_import_pipeline.conf',
        'viruses/viruses_mapping_pipeline.conf',  'viruses/viruses_qc_pipeline.conf',
        'viruses/viruses_rna_seq_pipeline.conf',  'viruses/viruses_stored_pipeline.conf'
    ],
);
execute_script_and_check_output($script_name, \%scripts_and_expected_files );

done_testing();

