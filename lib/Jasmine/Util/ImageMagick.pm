package Jasmine::Util::ImageMagick;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    r => [qw/path web_path max_width max_height/]
);
use File::Path ();
use Image::Magick;
use UUID::Random;

use Data::Dumper;

sub handle_uploads {
    my ($self, $req, $image_params, $width, $height) = @_;
    my $params = {};
    foreach my $param(@$image_params) {
	my $image = $req->uploads->{$param};
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
    my ($self, $path, $width, $height, $force_resize) = @_;

    if (-f $path) {
	my $im = Image::Magick->new;
	my $name = UUID::Random::generate;
	warn "$path $name";
	$name =~ m/((.).)/;
	my $dir = "$self->{path}/$2/$1";
	File::Path::mkpath($dir);
	my $file = "$dir/$name.jpg";
	warn "$path $name $dir $file";
	$im->Read($path);
	my($image_width, $image_height, $format) = $im->Get('width', 'height', 'format');
	warn "image: <$format> $image_width x $image_height";
	if ($width) {
	    if (!$force_resize) {
		$width = $width > $image_width ? $image_width : $width;
	    }
	    $width = $width > $self->{max_width} ? $self->{max_width} : $width;
	} else {
	    $width = $image_width > $self->{max_width} ? $self->{max_width} : $image_width;
	}
	if ($height) {
	    if (!$force_resize) {
		$height = $height > $image_height ? $image_height : $height;
	    }
	    $height = $height > $self->{max_height} ? $self->{max_height} : $height;
	} else {
	    $height = $image_height > $self->{max_height} ? $self->{max_height} : $image_height;
	}
	$im->Resize(geometry => "${width}x${height}");
	$im->Set(quality=>90);
	$im->Write("jpg:$file");
	undef $im;

	return -f $file ? $file : undef;
    } else {
	warn "$path does not exists!\n";
    }
}

1;
