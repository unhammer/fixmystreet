package FixMyStreet::App::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config( namespace => '' );

=head1 NAME

FixMyStreet::App::Controller::Root - Root Controller for FixMyStreet::App

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 auto

Set up general things for this instance

=cut

sub auto {
    my ( $self, $c ) = @_;

    return;
}

=head2 index

The root page (/)

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

=head2 default

Forward to the standard 404 error page

=cut

sub default : Path {
    my ( $self, $c ) = @_;
    $c->detach('/page_not_found');
}

=head2 page_not_found

    $c->detach('/page_not_found');

Display a 404 page.

=cut

sub page_not_found : Private {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'errors/page_not_found.html';
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
}

__PACKAGE__->meta->make_immutable;

1;