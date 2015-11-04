package TestHelper;

use Moose::Role;
use File::Find;
use File::Slurper qw[write_text read_text];
use Test::Most;
use Test::Files;
use Data::Dumper;

our @actual_files_found;
# default db file to be used for testing
our $test_database_connection_file = "t/data/database_connection_details"; 


# Execute script and check required files are created 
sub execute_script_and_check_output {
    my ( $script_name, $scripts_and_expected_files ) = @_;

    for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
        my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
        my $destination_directory = $destination_directory_obj->dirname();
        my $full_script = './bin/' . $script_name . ' ' . $script_parameters . " --db_file $test_database_connection_file --config_base $destination_directory --log_base $destination_directory "; #-l t/data/refs.index ";
        system("$full_script >/dev/null 2>&1");

        find( { wanted => \&process_file, no_chdir => 1 }, ($destination_directory) );
        
        my @temp_directory_stripped   = map { /$destination_directory\/(.+)/ ? $1 : $_ } sort @actual_files_found;
        my @sorted_directory_stripped = sort(@temp_directory_stripped);
        my @sorted_expected_values    = sort( @{ $scripts_and_expected_files->{$script_parameters} } );

        is_deeply( \@sorted_directory_stripped, \@sorted_expected_values,
            "files created as expected for $full_script" );
        @actual_files_found = ();
    }
}

# Mock execution of script and check if required files are created
sub mock_execute_script_and_check_output {
    my ( $script_name, $scripts_and_expected_files ) = @_;
    
    open OLDOUT, '>&STDOUT';
    eval("use $script_name ;");
    my $returned_values = 0;
    {
          local *STDOUT;
          open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";

        for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
            my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
            my $destination_directory = $destination_directory_obj->dirname();

            my $full_script = $script_parameters . " --db_file $test_database_connection_file --config_base $destination_directory --log_base $destination_directory -l t/data/refs.index ";
            my @input_args = split( " ", $full_script );
            
            my $cmd = "$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;";
            eval($cmd);

            find( { wanted => \&process_file, no_chdir => 1 }, ($destination_directory) );

            my @temp_directory_stripped   = map { /$destination_directory\/(.+)/ ? $1 : $_ } sort @actual_files_found;
            my @sorted_directory_stripped = sort(@temp_directory_stripped);
            my @sorted_expected_values    = sort( @{ $scripts_and_expected_files->{$script_parameters} } );

            is_deeply( \@sorted_directory_stripped, \@sorted_expected_values,
                "files created as expected for $full_script" );
            @actual_files_found = ();
        }
         close STDOUT;
    }
# Restore stdout.
      open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!"; 
# Avoid leaks by closing the independent copies.
      close OLDOUT or die "Can't close OLDOUT: $!";
}

# Mock execution of script and check that CONTENTS of config file is as expected
sub mock_execute_script_create_file_and_check_output {
   my ( $script_name, $scripts_and_expected_files ) = @_;

   open OLDOUT, '>&STDOUT';
   open OLDERR, '>&STDERR';
   eval("use $script_name ;");
   my $returned_values = 0;
   {
 		local *STDOUT;
        open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";
        local *STDERR;
        open STDERR, '>/dev/null' or warn "Can't open /dev/null: $!";

       for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
           my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
           my $destination_directory = $destination_directory_obj->dirname();
		
		   my $full_script = $script_parameters . " --test --db_file $test_database_connection_file --config_base $destination_directory --log_base /nfs/pathnfs05/log -l t/data/refs.index ";
           my @input_args = split( " ", $full_script );

           my $cmd = "$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;";
           eval($cmd);
           my $actual_output_file_name = $destination_directory . '/' . $scripts_and_expected_files->{$script_parameters}->[0];
           my $expected_output_file_name = $scripts_and_expected_files->{$script_parameters}->[1];
           ok(-e $actual_output_file_name, "Actual output file exists $actual_output_file_name");
	       strip_prefix_attribute($actual_output_file_name);
	       compare_ok($actual_output_file_name,$expected_output_file_name,"Actual and expected output match for '$script_parameters'");
           unlink($actual_output_file_name);

       }
       close STDOUT;
       close STDERR;
   }

   # Restore stdout.
   open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
   open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";
   
   # Avoid leaks by closing the independent copies.
   close OLDOUT or die "Can't close OLDOUT: $!";
   close OLDERR or die "Can't close OLDERR: $!";
}

sub process_file {
    if ( -f $_ ) {
        push( @actual_files_found, $File::Find::name );
    }
}

sub strip_prefix_attribute {
	my ($actual_output_file_name) = @_ ;
	my $lines = read_text($actual_output_file_name);
	$lines =~ s/'prefix' => '[\w]+'/'prefix' => '_checked_elsewhere_'/i;
	write_text($actual_output_file_name,$lines);
}

no Moose;
1;

