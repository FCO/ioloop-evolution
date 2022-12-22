package IOLoop;
use lib ".";
use Continuation;

use Moose;
has continuations => (is => "ro", isa => "ArrayRef", default => sub { [] });

sub start {
   my $self = shift;

   while(my $curr = shift $self->continuations->@*) {
      unless($curr->condition->()) { push $self->continuations->@*, $curr; next }

      $curr->code->($self)
   }
   $self
}

sub set_immidiate {
   my $self = shift;
   my $code = shift;

   push $self->continuations->@*, Continuation->new({ code => $code })
}

sub set_timeout {
   my $self = shift;
   my $code = shift;
   my $time = shift;

   my $now = time;
   push $self->continuations->@*, Continuation->new({ code => $code, condition => sub { time >= $now + $time } })
}

__PACKAGE__->meta->make_immutable;
