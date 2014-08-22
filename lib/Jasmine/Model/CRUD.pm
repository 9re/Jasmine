package Jasmine::Model::CRUD;
use strict;
use warnings;
use Data::Dumper;
use Class::Accessor::Lite (
    new => 1,
    r => [qw/table teng/]
);

sub create {
    my ($self, $params) = @_;
    $self->{teng}->insert(
	$self->{table},
	$params);
}

sub search {
    my ($self, $condition, $attr) = @_;
    $self->{teng}->search(
	$self->{table},
	$condition,
	$attr);
}

sub single {
    my ($self, $condition) = @_;
    $self->{teng}->single(
	$self->{table},
	$condition);
}

sub update {
    my ($self, $row_data, $condition) = @_;
    $self->{teng}->update(
	$self->{table},
	$row_data,
	$condition);
}

sub find_or_create{
    my ($self, $args) = @_;
    $self->{teng}->find_or_create(
	$self->{table},
	$args);
};

sub delete {
    my ($self, $condition) = @_;
    $self->{teng}->delete(
	$self->{table},
	$condition);
}

1;
