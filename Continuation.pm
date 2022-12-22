package Continuation;

use Moose;
has condition => (is => "ro", isa => "CodeRef", default => sub { sub { 1 } });
has code      => (is => "ro", isa => "CodeRef", required => 1);

__PACKAGE__->meta->make_immutable;
