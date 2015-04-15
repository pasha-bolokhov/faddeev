package Bibl::Schema::Result::BiblArticle;

# Created by DBIx::Class::Schema::Loader
# # DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Bibl::Schema::Result::BiblArticle

=cut

__PACKAGE__->table("bibl_articles");

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
  "item",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "author",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "lang",
  { data_type => "varchar", is_nullable => 0, size => 2, default_value => 'en' },
  "type",
  { data_type => "integer", is_nullable => 0, default_value => 1 },
  "comment",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "link",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "arxiv",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "spires",
  { data_type => "integer", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many('map_edition' => 'Bibl::Schema::Result::BiblEdition', {'foreign.article_id' => 'self.id'}, {cascade_delete => 1} );

1;
