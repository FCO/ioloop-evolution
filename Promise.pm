package Promise;
use lib ".";
use IOLoop;

use Moose;
has _code    => (is => "ro", isa => "CodeRef");
has _thens   => (is => "ro", isa => "ArrayRef", default => sub { [] });
has _catches => (is => "ro", isa => "ArrayRef", default => sub { [] });
has result   => (is => "rw");
has status   => (is => "ro", default => "pending");

sub resolve {
    my $class = shift;
    $class->new({ result => shift(), status => "kept" })
}

sub keep {
    my $self = shift;
    my $data = shift;
    $self->result($data);
    $self->{status} = "kept";
    for my $p($self->_thens->@*) {
        if($data->isa("Promise")) {
            push $data->_thens->@*, $p
        } else {
            $p->_start($data)
        }
    }
}

sub break {
    my $self = shift;
    my $data = shift;
    $self->result($data);
    $self->{status} = "broken";
    for my $p($self->_catches->@*) {
        $p->_start($data)
    }
    for my $p($self->_thens->@*) {
        $main::io_loop->set_immidiate(sub { $p->break($data) })
    }
}

sub _start {
    my $self = shift;
    my $data = shift;
    $main::io_loop->set_immidiate(sub {
        eval {
            $self->keep($self->_code->($data))
        };
        if($@) {
            $self->break($@)
        }
    });
    $self
}

sub start {
    my $class = shift;
    $class->new({ _code => shift() })->_start
}

sub then {
    my $self = shift;
    my $new = $self->new({ _code => shift() });
    push $self->_thens->@*, $new;
    if($self->status eq "kept") {
        $new->_start($self->result)
    } elsif($self->status eq "broken") {
        $new->break($self->result)
    }
    $new
}

sub catch {
    my $self = shift;
    my $new = $self->new({ _code => shift() });
    push $self->_catches->@*, $new;
    if($self->status eq "broken") {
        $new->_start($self->result)
    } elsif($self->status eq "kept") {
        $new->_start($self->result)
    }
    $new
}

sub in {
    my $class = shift;
    my $time  = shift;
    my $new = Promise->new;
    $main::io_loop->set_timeout(sub {
        $new->keep($time)
    }, $time);
    $new
}

__PACKAGE__->meta->make_immutable;
