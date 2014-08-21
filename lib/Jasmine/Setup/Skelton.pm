package Jasmine::Setup::Skelton;

use strict;
use warnings;
use utf8;

use Text::Xslate;
use File::Spec;
use File::Basename;
use File::Path ();
use Plack::Util ();
use File::ShareDir ();
use Module::CPANfile 0.9020;
use Jasmine;

sub new {
    my $class = shift;
    my %args = @_ ==1 ? %{$_[0]} : @_;

    $args{jasmine_version} = $Jasmine::VERSION;

    for (qw/module/) {
        die "Missing mandatory parameter $_" unless exists $args{$_};
    }
    $args{module} =~ s!-!::!g;

    # $module = "Foo::Bar"
    # $dist   = "Foo-Bar"
    # $path   = "Foo/Bar"
    my @pkg  = split /::/, $args{module};
    $args{dist} = join "-", @pkg;
    $args{path} = join "/", @pkg;
    my $self = bless { %args }, $class;
    $self->{xslate} = $self->_build_xslate();
    $self;
}

sub _build_xslate {
    my $self = shift;

    my $xslate = Text::Xslate->new(
        type   => 'text',
        path => [ File::Spec->catdir(File::ShareDir::dist_dir('Jasmine'), 'skelton') ],
    );
    $xslate;
}

sub infof {
    my $caller = do {
        my $x;
        for (1..10) {
            $x = caller($_);
            last if $x ne __PACKAGE__;
        }
        $x;
    };
    print "[$caller] ";
    @_==1 ? print(@_) : printf(@_);
    print "\n";
}

sub write_assets {
    
}

1;
