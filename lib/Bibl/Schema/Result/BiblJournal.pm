package Bibl::Schema::Result::BiblJournal;

# Created by DBIx::Class::Schema::Loader
# # DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Bibl::Schema::Result::BiblJournal

=cut

__PACKAGE__->table("bibl_journals");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "abbr",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "publisher",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "type",
  { data_type => "integer", is_nullable => 0, default_value => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many('map_edition' => 'Bibl::Schema::Result::BiblEdition', {'foreign.journal_id' => 'self.id'}, {cascade_delete => 0} );

1;
