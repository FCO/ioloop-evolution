package AsyncAwait;
use feature qw/say/;
use lib ".";
use Promise;

sub transform_async_func {
    my @code = split $/, shift;

    my (@tmp, @groups);
    for my $line(@code) {
        if($line =~ /^\s*await (.*)$/) {
            push @tmp, $1;
            push @groups, [ @tmp ];
            @tmp = ();
            next
        }
        push @tmp, $line
    }
    push @groups, [ @tmp ] if @tmp;

    my $first_block = join $/, (shift @groups)->@*;
    my @blocks = map { my $block = join $/, @$_; <<"EOB" } @groups;
    ->then(sub {
       $block 
    })
EOB

    my $code = <<"EOF";
    sub {
        Promise->start(sub {
            $first_block
        })
EOF

    $code .= join $/, @blocks;
    $code .= "}";
    # say $code;
    my $sub = eval $code;
    die $@ if $@;
    $sub
}

1;
