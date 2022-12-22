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
