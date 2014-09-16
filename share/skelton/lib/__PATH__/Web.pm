package <: $module :>::Web;

use strict;
use warnings;
use utf8;
use Jasmine;
use <: $module :>::Container qw/model/;

enable_filter qw/session anti_csrf get_user require_user/;
filter_option
    require_user => {
	redirect_path => '/'
    },
    get_user => {
	get_user_sub => sub {
	    my ($user_id) = @_;
	    $user_id ? model('User')->single({id => $user_id}) : undef;
	}
    }
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

