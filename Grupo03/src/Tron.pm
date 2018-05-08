package Tron;

sub TRACE {
    if (! $TRON) { return; }

    foreach $x (@_) { print $x; }
    print "\n";
}

1;
