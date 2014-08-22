use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Text::Xslate;
use File::Basename;
use Data::Section::Simple qw(get_data_section);

pod2usage(0) unless @ARGV;
GetOptions(
    'help' => \my $help
) or pod2usage(0);
pod2usage(1) if $help;

my $table_name = $ARGV[0];

my $model_name = $table_name;
$model_name =~ s/^(\w)/uc($1)/ge;
$model_name =~ s/_(\w)/uc($1)/ge;


my $files = get_data_section();
my $args = {
    table_name => $table_name,
    model_name => $model_name,
    
};

my $tx = Text::Xslate->new(syntax => 'TTerse');
foreach my $fkey ( keys %{$files} ) {
    my $path = $tx->render_string($fkey, $args);
    my $content = $tx->render_string($files->{$fkey}, $args);
    print "$path\n$content";
}

=head1 SYNOPSIS

    % perl script/create_model.pl table_name

=cut
__DATA__
@@ lib/<: $path :>/Model/[% $model_name %].pm
package <: $module :>::Model::[% $model_name %];
use strict;
use warnings;
use parent 'Jasmine::Model::CRUD';
use <: $module :>::Container;
use Data::Dumper;

sub new {
    my ($class) = +shift;
    my $self = $class->SUPER::new(
	table => '[% $table_name %]',
	teng => obj('db'));
    return $self;
}

1;
