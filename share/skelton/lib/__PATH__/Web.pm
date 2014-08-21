package <: $module :>::Web;

use strict;
use warnings;
use utf8;
use Jasmine;

enable_filter qw/session anti_csrf require_user/;
filter_option
    require_user => {
	redirect_path => '/'
    },
    ;

get '/' => [qw/session/] => sub {
    my ( $self, $c )  = @_;
    $c->render('index.tx', { greeting => "Hello" });
};

get '/mypage' => [qw/session require_user/] => sub {
    my ( $self, $c )  = @_;
    $c->halt(404);
};

1;

