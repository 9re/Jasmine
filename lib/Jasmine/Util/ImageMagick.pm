package Jasmine::Util::ImageMagick;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    r => [qw/path web_path/]
);
use File::Path ();
use Image::Magick;
use UUID::Random::generate;

sub handle_params {
    my ($self, $req, $params, $width, $height) = @_;
    my $params = {};
    foreach my $param(@$params) {
	my $image = $req->upload($param);
	if ($image) {
	    my $uploaded = $self->create_thumbnail($image->tempname, $width, $height);
	    if ($uploaded) {
		$uploaded =~ s|$root_dir|/$self->{web_path}|;
		$params->{$param} = $uploaded;
	    }
	}
    }
    return $params;
}

sub create_thumbnail {
    my ($self, $path, $width, $height) = @_;

    if (-f $path) {
	my $im = Image::Magick->new;
	my $name = UUID::Random::generate;
	$name =~ m/((.).)/;
	my $dir = "$self->{path}/$2/$1";
	File::Path::mkpath($dir);
	my $file = "$dir/$name.jpg";
	#`convert -resize 640x640 $path $file`;
	$im->Read($path);
	$im->Resize(width => $width, height => $height);
	$im->Write($file);

	return -f $file ? $file : undef;
    }
}


1;
