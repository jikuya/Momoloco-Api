use strict;
use warnings;
use Module::Build;

my $build = Module::Build->subclass(
    code => q{
        sub ACTION_install {
            die "Do not install web application.\n";
        }

        # do not make blib.
        sub ACTION_code {
            my $self = shift;
            $self->depends_on('config_data');
        }

        # run prove
        sub ACTION_test {
            my $self = shift;
            my $tests = $self->find_test_files;

            require App::Prove;
            my $prove = App::Prove->new();
            $prove->process_args('-l', @$tests);
            $prove->run();
        }
    }
)->new(
    license              => 'unknown',
    dynamic_config       => 0,

    build_requires       => {
        'Test::More' => '0.98',
        'Test::Requires' => 0,
    },
    configure_requires   => { 'Module::Build' => '0.38' },
    requires             => {
        perl => '5.008001',
        'Amon2'                           => '3.66',
        'Text::Xslate'                    => '1.6001',
        'Amon2::DBI'                      => '0.30',
        'DBD::SQLite'                     => '1.33',
        'HTML::FillInForm::Lite'          => '1.11',
        'JSON'                            => '2.50',
        'Plack::Middleware::ReverseProxy' => '0.09',
        'Plack::Middleware::Session'      => '0',
        'Plack::Session'                  => '0.14',
        'Test::WWW::Mechanize::PSGI'      => '0',
        'Time::Piece'                     => '1.20',
	# momoloco
        'Starman'                         => '0.3006',
        'Server::Starter'                 => '0.12',
        'Net::Server::SS::PreFork'        => '0.05',
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Momoloco::Api',
    module_name => 'Momoloco::Api',
    author        => 'Some Person <person@example.com>',
    dist_abstract => 'A web site based on Amon2',

    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,

    create_readme  => 0,
    create_license => 0,
);
$build->create_build_script();
