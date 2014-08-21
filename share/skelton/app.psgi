use FindBin;
use lib "$FindBin::Bin/extlib";
use lib "$FindBin::Bin/lib";
use File::Basename;
use Plack::Builder;
use <: $module :>::Web;
use Plack::Middleware::Debug;
use Plack::Session::Store::File;
use Plack::Session::State::Cookie;

my $root_dir = File::Basename::dirname(__FILE__);

my $app = <: $module :>::Web->psgi($root_dir);
builder {
    enable 'Debug'; # load defaults
    enable 'Debug::DBITrace', level => 2;
    enable 'ReverseProxy';
    enable 'Plack::Middleware::Session',
        store => Plack::Session::Store::File->new(
	    dir => "$root_dir/tmp/session"
	),
        state => Plack::Session::State::Cookie->new(
	    httponly => 1,
	    session_key => 'session',
	    path => '/'
        );
    ;
    enable 'Static',
        path => qr!^/(?:(?:css|js|img)/|favicon\.ico$)!,
        root => $root_dir . '/public';
    $app;
};

