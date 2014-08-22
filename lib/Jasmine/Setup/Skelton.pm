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
use File::Find ();
use File::Copy ();
use Module::CPANfile 0.9020;
use Data::Dumper;
require Jasmine;

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

sub mkpath {
    my ($self, $path) = @_;
    Carp::croak("path should not be ref") if ref $path;
    infof("mkpath: $path");
    File::Path::mkpath($path);
}

sub render_string {
    my $self = shift;
    my $template = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    return $self->{xslate}->render_string($template, {%$self, %args});
}

sub render_file {
    my ($self, $dstname, $filename, $params) = @_;
    Carp::croak("filename should not be reference") if ref $filename;
    $dstname =~ s/<<([^>]+)>>/$self->{lc($1)} or die "$1 is not defined. But you want to use $1 in filename."/ge;

    my $content = $self->{xslate}->render($filename, {%$self, $params ? %$params : () });
    $self->write_file_raw($dstname, $content);
}

sub write_file {
    my ($self, $filename, $template) = (shift, shift, shift);
    Carp::croak("filename should not be reference") if ref $filename;

    $filename =~ s/<<([^>]+)>>/$self->{lc($1)} or die "$1 is not defined. But you want to use $1 in filename."/ge;

    my $content = $self->render_string($template, @_);
    $self->write_file_raw($filename, $content);
}

sub write_file_raw {
    my ($self, $filename, $content, $input_mode) = @_;
    Carp::croak("filename should not be reference") if ref $filename;
    $input_mode ||= '>:encoding(utf-8)';

    infof("writing $filename");

    my $dirname = dirname($filename);
    File::Path::mkpath($dirname) if $dirname;

    open my $ofh, $input_mode, $filename or die "Cannot open file: $filename: $!";
    print {$ofh} $content;
    close $ofh;
}

sub copy_shared_files {
    my ($self, $target_dir) = @_;
    my $dir = File::ShareDir::dist_dir('Jasmine');
    my $public_dir = File::Spec->catdir($dir, $target_dir);
    my @files = ();
    File::Find::find(
	sub {
	    return if -d;
	    my $file = $File::Find::name;
	    $file =~ s|$public_dir/||;
	    push @files, "$file";
	}, $public_dir);

    foreach my $file(@files) {
	my $dest = "$target_dir/$file";
	my $dirname = dirname($dest);
	$self->mkpath($dirname) unless -d $dirname;
	File::Copy::copy("$public_dir/", $dest);
    }
}

1;
