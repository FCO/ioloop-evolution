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
