package Jasmine::Util::ImageMagick;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    r => [qw/path web_path/]
);
use File::Path ();
use Image::Magick;
use UUID::Random;

use Data::Dumper;

sub handle_uploads {
    my ($self, $req, $image_params, $width, $height) = @_;
    my $params = {};
    foreach my $param(@$image_params) {
	my $image = $req->upload($param);
	if ($image) {
	    my $uploaded = $self->create_thumbnail($image->tempname, $width, $height);
	    if ($uploaded) {
		$uploaded =~ s|$self->{path}|/$self->{web_path}|;
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
	$im->Resize(geometry => "${width}x${height}");
	$im->Write($file);

	return -f $file ? $file : undef;
    }
}


1;
