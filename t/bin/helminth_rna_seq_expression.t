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

my $script_name = 'Bio::VertRes::Config::CommandLine::HelminthRnaSeqExpression';

my %scripts_and_expected_files = (
    '-t file -i t/data/lanes_file -r ABC' => [
        'command_line.log',
        'helminths/helminths_import_cram_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',
       
        'helminths/import_cram/import_cram_global.conf',
        'helminths/mapping/mapping_1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name_ABC_tophat.conf',
        'helminths/rna_seq/rna_seq_1111_2222_3333_lane_name_another_lane_name_a_very_big_lane_name_ABC.conf',
        
    ],
    '-t lane -i 1234_5#6 -r ABC' => [
        'command_line.log',
        'helminths/helminths_import_cram_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf', 
        'helminths/helminths_rna_seq_pipeline.conf', 
        'helminths/import_cram/import_cram_global.conf',        'helminths/mapping/mapping_1234_5_6_ABC_tophat.conf',
        'helminths/rna_seq/rna_seq_1234_5_6_ABC.conf',
        
    ],
    '-t library -i libname -r ABC' => [
        'command_line.log',
        'helminths/helminths_import_cram_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf', 
        'helminths/import_cram/import_cram_global.conf',        'helminths/mapping/mapping_libname_ABC_tophat.conf',
        'helminths/rna_seq/rna_seq_libname_ABC.conf',
        
    ],
    '-t sample -i sample -r ABC' => [
        'command_line.log',
        'helminths/helminths_import_cram_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf', 
        'helminths/import_cram/import_cram_global.conf',        'helminths/mapping/mapping_sample_ABC_tophat.conf',
        'helminths/rna_seq/rna_seq_sample_ABC.conf',
        
    ],
    '-t study -i ZZZ -r ABC -p "StrandSpecificProtocol"' => [
        'command_line.log',
        'helminths/helminths.ilm.studies',
        'helminths/helminths_import_cram_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',
             'helminths/import_cram/import_cram_global.conf',
        'helminths/mapping/mapping_ZZZ_ABC_tophat.conf',
        'helminths/rna_seq/rna_seq_ZZZ_ABC.conf',        
    ],
    '-t study -i ZZZ -r ABC -s Staphylococcus_aureus' => [
        'command_line.log',
        'helminths/helminths.ilm.studies',
        'helminths/helminths_import_cram_pipeline.conf',
        'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',
       
        'helminths/import_cram/import_cram_global.conf',
        'helminths/mapping/mapping_ZZZ_Staphylococcus_aureus_ABC_tophat.conf',
        'helminths/rna_seq/rna_seq_ZZZ_Staphylococcus_aureus_ABC.conf',
        
    ],
    '-t study -i ZZZ -r ABC' => [
        'command_line.log',
        'helminths/helminths.ilm.studies',
        'helminths/helminths_import_cram_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',
             'helminths/import_cram/import_cram_global.conf',
        'helminths/mapping/mapping_ZZZ_ABC_tophat.conf',
        'helminths/rna_seq/rna_seq_ZZZ_ABC.conf',        
    ],
     '-t study -i ZZZ -r ABC -m smalt' =>   [
         'command_line.log',
         'helminths/helminths.ilm.studies',
         'helminths/helminths_import_cram_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
        'helminths/helminths_rna_seq_pipeline.conf',
              'helminths/import_cram/import_cram_global.conf',
         'helminths/mapping/mapping_ZZZ_ABC_smalt.conf', 
         'helminths/rna_seq/rna_seq_ZZZ_ABC.conf',        
     ],
     '-t study -i ZZZ -r ABC -m bwa' =>   [
         'command_line.log',
         'helminths/helminths.ilm.studies',
         'helminths/helminths_import_cram_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
                  'helminths/helminths_rna_seq_pipeline.conf',
              'helminths/import_cram/import_cram_global.conf',
         'helminths/mapping/mapping_ZZZ_ABC_bwa.conf',
         'helminths/rna_seq/rna_seq_ZZZ_ABC.conf',        
     ],
     '-t study -i ZZZ -r ABC -m bowtie2' =>   [
         'command_line.log',
         'helminths/helminths.ilm.studies',
         'helminths/helminths_import_cram_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
               'helminths/helminths_rna_seq_pipeline.conf',
              'helminths/import_cram/import_cram_global.conf',
         'helminths/mapping/mapping_ZZZ_ABC_bowtie2.conf', 
         'helminths/rna_seq/rna_seq_ZZZ_ABC.conf',        
     ],
     '-t study -i ZZZ -r ABC -m stampy' =>   [
         'command_line.log',
         'helminths/helminths.ilm.studies',
         'helminths/helminths_import_cram_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
                  'helminths/helminths_rna_seq_pipeline.conf',
              'helminths/import_cram/import_cram_global.conf',
         'helminths/mapping/mapping_ZZZ_ABC_stampy.conf',
         'helminths/rna_seq/rna_seq_ZZZ_ABC.conf',        
     ],
     '-t study -i ZZZ -r ABC -m smalt --smalt_index_k 15 --smalt_index_s 4 --smalt_mapper_r 1 --smalt_mapper_y 0.9 --smalt_mapper_x' =>   [
         'command_line.log',
         'helminths/helminths.ilm.studies',
         'helminths/helminths_import_cram_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
                 'helminths/helminths_rna_seq_pipeline.conf',
              'helminths/import_cram/import_cram_global.conf',
         'helminths/mapping/mapping_ZZZ_ABC_smalt.conf', 
         'helminths/rna_seq/rna_seq_ZZZ_ABC.conf',        
     ],
     '-t study -i ZZZ -r ABC --tophat_mapper_max_intron 10000 --tophat_mapper_min_intron 70 --tophat_mapper_max_multihit 1' =>   [
         'command_line.log',
         'helminths/helminths.ilm.studies',
         'helminths/helminths_import_cram_pipeline.conf',      'helminths/helminths_mapping_pipeline.conf',
                 'helminths/helminths_rna_seq_pipeline.conf',
              'helminths/import_cram/import_cram_global.conf',
         'helminths/mapping/mapping_ZZZ_ABC_tophat.conf', 
         'helminths/rna_seq/rna_seq_ZZZ_ABC.conf',        
     ],
     
     
    '-a ABC ' => ['command_line.log'],

);

mock_execute_script_and_check_output_ignore_regex( $script_name, \%scripts_and_expected_files,'permission' );

%scripts_and_expected_files = (
    '-t study -i ZZZ -r ABC -m tophat' => [
        'helminths/mapping/mapping_ZZZ_ABC_tophat.conf',
        't/data/expected/helminth_mapping_ZZZ_ABC_tophat_fstrand.conf'
    ],
'-t study -i ZZZ -r ABC -m tophat --tophat_mapper_library_type fr-unstranded'
      => [
        'helminths/mapping/mapping_ZZZ_ABC_tophat.conf',
        't/data/expected/helminth_mapping_ZZZ_ABC_tophat.conf'
      ],
'-t study -i ZZZ -r ABC -m tophat --tophat_mapper_library_type fr-firststrand'
      => [
        'helminths/mapping/mapping_ZZZ_ABC_tophat.conf',
        't/data/expected/helminth_mapping_ZZZ_ABC_tophat_fstrand.conf'
      ],
'-t study -i ZZZ -r ABC -m tophat --tophat_mapper_library_type fr-secondstrand'
      => [
        'helminths/mapping/mapping_ZZZ_ABC_tophat.conf',
        't/data/expected/helminth_mapping_ZZZ_ABC_tophat_sstrand.conf'
      ],
);

mock_execute_script_create_file_and_check_output( $script_name,
    \%scripts_and_expected_files );

done_testing();

