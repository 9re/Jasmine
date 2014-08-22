package <: $model :>::Model::Password;
use <: $model :>::Container;
use Digest::SHA qw/hmac_sha256_hex/;

sub new { bless {}, +shift }

sub hash {
    my ($self, $password) = @_;
    
    my $conf = obj('conf')->{Salt};
    my $prefix = $conf->{prefix};
    my $suffix = $conf->{suffix};
    
    hmac_sha256_hex("$prefix:$password:$suffix", $conf->{salt});
}

sub is_equal {
    my ($self, $password, $hash) = @_;
    $hash eq $self->hash($password);
}

1;
