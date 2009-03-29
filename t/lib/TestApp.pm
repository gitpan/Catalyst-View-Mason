package TestApp;

use strict;
use warnings;
use Scalar::Util qw/blessed/;
use Catalyst;

our $VERSION = '0.01';

__PACKAGE__->config(
        name                     => 'TestApp',
        default_view             => 'Mason::Appconfig',
        default_message          => 'hi',
        'View::Mason::Appconfig' => {
            default_escape_flags => ['h'],
            use_match            => 0,
        },
);

if ($::use_root_string) {
    __PACKAGE__->config(root => __PACKAGE__->config->{root}->stringify);
}

__PACKAGE__->config(
        setup_components => {
            except => qr/^View::Mason::CompRootRef$/,
        },
);

__PACKAGE__->log( $::fake_log || Catalyst::Log->new(qw/debug info error fatal/) );

__PACKAGE__->setup;

sub test : Local {
    my ($self, $c) = @_;

    $c->stash->{message} = ($c->request->param('message') || $c->config->{default_message});
}

sub test_set_template : Local {
    my ($self, $c) = @_;

    $c->forward('test');
    $c->stash->{template} = 'test';
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

    my $out = $self->view->render(
            $c, $c->request->param('template'),
            { param => $c->req->param('param') || '' },
    );

    $c->response->body($out);

    if (blessed($out) && $out->isa('HTML::Mason::Exception')) {
        $c->response->status(403);
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

sub comp_path : Local {
    my ($self, $c) = @_;

    $c->stash->{param} = 'bar';
}

sub end : Private {
    my ($self, $c) = @_;

    return 1 if $c->response->status =~ /^3\d\d$/;
    return 1 if $c->response->body;

    my ($requested_view) = $c->request->param('view');
    $c->forward($c->view( $requested_view ? $requested_view : () ));
}

1;
