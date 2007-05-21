package TestApp;

use strict;
use warnings;
use Scalar::Util qw/blessed/;
use Catalyst;

our $VERSION = '0.01';

__PACKAGE__->config(
        name                     => 'TestApp',
        default_view             => 'Pkgconfig',
        default_message          => 'hi',
        'View::Mason::Appconfig' => {
            default_escape_flags => ['h'],
        },
);

__PACKAGE__->setup;

sub test : Local {
    my ($self, $c) = @_;

    $c->stash->{message} = ($c->request->param('message') || $c->config->{default_message});
}

sub test_content_type : Local {
    my ($self, $c) = @_;

    $c->forward('test');

    $c->stash->{template} = '/test';

    $c->response->content_type('text/html; charset=iso8859-1')
}

sub exception : Local {
    my ($self, $c) = @_;

    $c->log->abort(1); #silence errors
}

sub render : Local {
    my ($self, $c) = @_;

    my $out = $c->stash->{message} = $self->view->render(
            $c, $c->request->param('template'),
            { param => $c->req->param('param') || '' },
    );

    if (blessed($out) && $out->isa('HTML::Mason::Exception')) {
        $c->response->body($out);
        $c->response->status(403);
    }
    else {
        $c->stash->{template} = 'test';
    }
}

sub match : Regex('^match/(\w+)') {
    my ($self, $c) = @_;

    $c->stash->{message} = $c->request->captures->[0];
}

sub action_match : Regex('^action_match/(\w+)') {
    my ($self, $c) = @_;

    $c->stash->{message} = $c->request->captures->[0];
}

sub globals : Local {
}

sub additional_globals : Local {
}

sub end : Private {
    my ($self, $c) = @_;

    return 1 if $c->response->status =~ /^3\d\d$/;
    return 1 if $c->response->body;

    my $view = 'Mason::' . ($c->request->param('view') || $c->config->{default_view});
    $c->forward( $c->view($view) );
}

1;
