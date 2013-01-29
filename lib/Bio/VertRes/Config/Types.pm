package Bio::VertRes::Config::Types;

# ABSTRACT: Moose types to use for validation.

=head1 SYNOPSIS

Moose types to use for validation.

=cut

use Moose;
use Moose::Util::TypeConstraints;
use Bio::VertRes::Config::Validate::Prefix;

subtype 'Bio::VertRes::Config::Prefix', as 'Str', where { Bio::VertRes::Config::Validate::Prefix->new()->is_valid($_) };

no Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;
1;
