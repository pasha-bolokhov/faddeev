package Bibl::Schema::Result::BiblEdition;

# Created by DBIx::Class::Schema::Loader
# # DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Bibl::Schema::Result::BiblEdition

=cut

__PACKAGE__->table("bibl_editions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 item

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "article_id",
  { data_type => "integer", is_nullable => 0},
  "journal_id",
  { data_type => "integer", is_nullable => 0},
  "year",
  { data_type => "integer", is_nullable => 1},
  "issue",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "vol",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "pages",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "type",
  { data_type => "integer", is_nullable => 0, default_value => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to('map_journal' => 'Bibl::Schema::Result::BiblJournal', {'foreign.id' => 'self.journal_id'}, {cascade_delete => 0} );
__PACKAGE__->belongs_to('map_article' => 'Bibl::Schema::Result::BiblArticle', {'foreign.id' => 'self.article_id'}, {cascade_delete => 0} );

1;
