use feature qw/say/;
no warnings;
use lib ".";

use Promise;

$main::io_loop = IOLoop->new;
$main::io_loop->set_immidiate(sub {
    Promise->in(1)
        ->then(sub { say "after 1/5"; Promise->in(1) })
        ->then(sub { say "after 2/5"; Promise->in(1) })
        ->then(sub { say "after 3/5"; Promise->in(1) })
        ->then(sub { say "after 4/5"; Promise->in(1) })
        ->then(sub { say "after 5/5"; }) ;

    Promise->start(sub { say "inside the promise"; Promise->in(3) })
        ->then(sub  { say "on then (after 3 secs. It sis not wait the 5/5)" })
        ->then(sub  { say "it seems to be working" })
        ->then(sub  { die "if it dies" })
        ->then(sub  { say "this will never run" })
        ->catch(sub { say "ERROR: ", shift; })
        ->then(sub  { say "but then it returns a clean promise" })
    ;
});

$main::io_loop->start
