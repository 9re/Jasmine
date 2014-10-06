package Jasmine::Util::Sendmail;

use strict;
use warnings;
use utf8;
use Mouse;
use Email::MIME;
use Email::MIME::Creator;
use Email::Sender::Simple qw/sendmail/;
use Encode;
use Data::Dumper;
use Try::Tiny;
use 5.014;


has from_name => (is => 'rw', isa => 'Str');
has from => (is => 'rw', isa => 'Str');
has to => (is => 'rw', isa => 'Str');
has title => (is => 'rw', isa => 'Str');
has body => (is => 'rw', isa => 'Str');

sub create {
    my ($self) = @_;

    my $from_name = $self->{from_name};
    my $from = $self->{from};
    my $email = Email::MIME->create(
	header => [
	    From =>  encode('MIME-Header-ISO_2022_JP' => "$from_name <$from>"),
	    To => encode('MIME-Header-ISO_2022_JP' => $self->{to}),
	    Subject => encode('MIME-Header-ISO_2022_JP' => $self->{title})
	],
	attributes => {
	    content_type => 'text/plain',
	    charset      => 'ISO-2022-JP',
	    encoding     => '7bit',
	},
	body => encode('iso-2022-jp' => $self->{body}),
	);

    return $email;
}

sub send {
    my ($self) = @_;

    my $mail = $self->create;
    try {
	sendmail($mail);
    } catch {
	warn "sending failed: $_";
    }
}


__PACKAGE__->meta->make_immutable();
__END__
