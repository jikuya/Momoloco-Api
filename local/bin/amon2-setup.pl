#!/home/jikuya/perl5/perlbrew/perls/perl-5.16.2/bin/perl 

eval 'exec /home/jikuya/perl5/perlbrew/perls/perl-5.16.2/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Amon2::Setup::Flavor::Basic;
use Amon2::Setup::VC::Git;
use Cwd ();
use Plack::Util;

my @flavors;
my $vc = 'Git';
GetOptions(
    'help'      => \my $help,
    'flavor=s@' => \@flavors,
	'vc=s'      => \$vc,
    'version'   => \my $version,
) or pod2usage(0);
if ($version) {
    require Amon2;
    print "Amon2: $Amon2::VERSION\n";
    exit(0);
}
pod2usage(1) if $help;
push @flavors, 'Basic' if @flavors == 0;
@flavors = map { split /,/, $_ } @flavors;

&main;exit;

sub main {
    my $module = shift @ARGV or pod2usage(0);
       $module =~ s!-!::!g;

    # $module = "Foo::Bar"
    # $dist   = "Foo-Bar"
    # $path   = "Foo/Bar"
    my @pkg  = split /::/, $module;
    my $dist = join "-", @pkg;
    my $path = join "/", @pkg;

    mkdir $dist or die "Cannot mkdir '$dist': $!";
    chdir $dist or die $!;

    my @flavor_classes;
    for my $flavor (@flavors) {
        my $flavor_class = load_flavor($flavor);
        push @flavor_classes, $flavor_class;

        print "-- Running flavor: $flavor --\n";

        my $cwd = Cwd::getcwd(); # save cwd
            {
                my $flavor = $flavor_class->new(module => $module);
                   $flavor->run;
            }
        chdir($cwd);
    }

	{
		$vc = Plack::Util::load_class($vc, 'Amon2::Setup::VC');
		$vc = $vc->new();
		$vc->do_import();
	}

    for my $flavor_class (@flavor_classes) {
        if ($flavor_class->can('call_trigger')) {
            $flavor_class->call_trigger('AFTER_VC');
        }
    }
}

sub load_flavor {
    my $flavor_name = shift;

    my $flavor_class = $flavor_name =~ s/^\+// ? $flavor_name : "Amon2::Setup::Flavor::$flavor_name";
    eval "use $flavor_class; 1" or die "Cannot load $flavor_class: $@";

    return $flavor_class;
}

__END__

=head1 NAME

amon2-setup.pl - setup script for amon2

=head1 SYNOPSIS

    % amon2-setup.pl MyApp

        --flavor=Basic   basic flavour(default)
        --flavor=Lite    Amon2::Lite flavour
        --flavor=Minimum minimalistic flavour for benchmarking

        --help   Show this help

=head1 DESCRIPTION

This is a setup script for Amon2.

amon2-setup.pl is highly extensible. You can write your own flavor.

=head1 HINTS

You can specify C<< --flavor >> option multiple times. For example, you can
type like following:

    % amon2-setup.pl --flavor=Basic --flavor=Teng MyApp

    % amon2-setup.pl --flavor=Teng,Basic MyApp

Second flavor can overwrite files generated by first flavor.

=head1 AUTHOR

Tokuhiro Matsuno

=cut
