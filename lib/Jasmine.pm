package Jasmine;

use 5.008004;
use strict;
use warnings;

use Kossy;
use Data::Dumper;
use Try::Tiny;

our $VERSION = "0.02";
our @EXPORT = qw/new root_dir psgi build_app _router _connect get post router filter _wrap_filter
                 enable_filter filter_option set_session_vars get_session_var/;
our @ISA = qw/Kossy Exporter/;

my $_FILTER_OPTIONS = {};
my $_FILTERS = {
    session => sub {
	my ($app) = @_;
	sub {
	    my ($self, $c) = @_;
	    my $sid = $c->req->env->{"psgix.session.options"}->{id};
	    
	    $c->stash->{session_id} = $sid;
	    $c->stash->{session}    = $c->req->env->{"psgix.session"};
	    $app->($self, $c);
	};
    },
    anti_csrf => sub {
	my ($app) = @_;
	sub {
	    my ($self, $c) = @_;
	    my $sid   = $c->req->param('sid');
	    my $token = $c->req->env->{'psgix.session'}->{token};
	    if ($sid ne $token) {
		return $c->halt(400);
	    }
	    $app->($self, $c);
	};
    },
    get_user => sub {
	my ($app) = @_;
	sub {
	    my ($self, $c) = @_;

	    my $user_id = $c->req->env->{'psgix.session'}->{user_id};
	    my $user = $_FILTER_OPTIONS->{get_user}->{get_user_sub}->($user_id);
	    $c->stash->{user} = $user;
	    $c->res->header('Cache-Control', 'private') if $user;
	    $app->($self, $c);
	}
    },
    require_user => sub {
	my ($app) = @_;
	sub {
	    my ($self, $c) = @_;
	    unless ($c->stash->{user}) {
		return $c->redirect($_FILTER_OPTIONS->{require_user}->{redirect_path});
	    }
	    $app->($self, $c);
	};
    },
};


sub enable_filter {
    foreach my $filter(@_) {
	if ($_FILTERS->{$filter}) {
	    filter $filter => $_FILTERS->{$filter};
	}
    }
}

sub filter_option {
    my %args = @_;
    while (my ($filter, $options) = each %args) {
	$_FILTER_OPTIONS->{$filter} = $options;
    }
}

sub set_session_vars {
    my ($self, $c, $vars) = @_;

    my $session = $c->req->env->{"psgix.session"};
    while (my ($key, $value) = each %$vars) {
	$session->{$key} = $value;
    }
}

sub get_session_var {
    my ($self, $c, $name) = @_;
    return $c->req->env->{"psgix.session"}->{$name};
}


1;
__END__

=encoding utf-8

=head1 NAME

Jasmine - It's new $module

=head1 SYNOPSIS

    use Jasmine;

=head1 DESCRIPTION

Jasmine is ...

=head1 LICENSE

Copyright (C) Taro Kobayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Taro Kobayashi E<lt>9re.3000@gmail.comE<gt>

=cut

