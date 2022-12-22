Evolution of IO Loop, Promise and Async/Await
---------------------------------------------

Small examples of minimal implementations. Just studying.

IO Loop:
========

```perl
use feature qw/say/;
no warnings;
use lib ".";

use IOLoop;

my $io_loop = IOLoop->new;
$io_loop->set_immidiate(sub {
    my $loop = shift;
    say "begin";
    $loop->set_timeout(sub {
        say "direct waited 3 secs (in 'parallel')";
      }, 3);
    $loop->set_timeout(sub {
        say "after 1 secs";
        $loop->set_timeout(sub {
            say "after 2 secs";
            $loop->set_timeout(sub {
                say "after 3 secs";
                $loop->set_timeout(sub {
                    say "after 4 secs";
                    $loop->set_timeout(sub {
                        say "after 5 secs";
                      }, 1);
                  }, 1);
              }, 1);
          }, 1);
    }, 1);
    say "end"
  });

$io_loop->start
```

Promise:
========

```perl
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
```

Async/Await:
============

```perl
use feature qw/say/;
no warnings;
use lib ".";

use Promise;
use AsyncAwait;

$main::io_loop = IOLoop->new;
*func1 = AsyncAwait::transform_async_func(<<'EOF');
    say "inside func1";
    await Promise->in(3);
EOF

*func2 = AsyncAwait::transform_async_func(<<'EOF');
    await main::func1();
    say "on then (after 3 secs)";
    await Promise->in(1);
    say "it seems to be working";
    await Promise->in(1);
    say "it works!!!";
    await Promise->in(1);
EOF

func2();

$main::io_loop->start
```
