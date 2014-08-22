package <: $module :>::Container;
use Object::Container::Exporter -base;
use File::Basename;

register_namespace model => '<: $module :>::Model';
register_default_container_name 'obj';

register conf => sub {
    my ($self) = @_;

    my $root_dir = File::Basename::dirname(__FILE__) . "/../..";
    my $config = do "$root_dir/config/config.pl";
};

register db => sub {
    my $self = shift;
    $self->load_class('<: $module :>::Model::DB');
    <: $module :>::Model::DB->new($self->get('conf')->{Teng});
};

register imagemagick => sub {
    my $self = shift;
    require Jasmine::Util::ImageMagick;
    Jasmine::Util::ImageMagick->new(
	$self->get('conf')->{ImageMagick});
};

1;
