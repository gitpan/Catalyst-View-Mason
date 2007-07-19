package Catalyst::View::Mason;

use strict;
use warnings;
use base qw/Catalyst::View/;
use Scalar::Util qw/blessed/;
use File::Spec;
use HTML::Mason;
use NEXT;

our $VERSION = '0.09_07';

__PACKAGE__->mk_accessors('template');

=head1 NAME

Catalyst::View::Mason - Mason View Class

=head1 SYNOPSIS

    # use the helper
    script/create.pl view Mason Mason

    # lib/MyApp/View/Mason.pm
    package MyApp::View::Mason;

    use base 'Catalyst::View::Mason';

    __PACKAGE__->config(use_match => 0);

    1;

    $c->forward('MyApp::View::Mason');

=head1 DESCRIPTION

Want to use a Mason component in your views? No problem!
Catalyst::View::Mason comes to the rescue.

=head1 EXAMPLE

From the Catalyst controller:

    $c->stash->{name} = 'Homer'; # Pass a scalar
    $c->stash->{extra_info} = {
               last_name => 'Simpson',
               children => [qw(Bart Lisa Maggie)]
    }; # A ref works too

From the Mason template:

    <%args>
    $name
    $extra_info
    </%args>
    <p>Your name is <strong><% $name %> <% $extra_info->{last_name} %></strong>
    <p>Your children are:
    <ul>
    % foreach my $child (@{$extra_info->{children}}) {
    <li>$child
    % }
    </ul>

=head1 METHODS

=cut

=head2 new($c, \%config)

=cut

sub new {
    my ($self, $c, $arguments) = @_;

    my %config = (
        comp_root          => $c->config->{root} . q//, # stringify
        data_dir           => File::Spec->tmpdir,
        use_match          => 1,
        allow_globals      => [],
        template_extension => q//,
        %{ $self->config },
        %{ $arguments },
    );

    unshift @{ $config{allow_globals} }, qw/$c $base $name/;
    $self = $self->NEXT::new($c, \%config);
    $self->{output} = q//;

    $self->config({ %config });

    delete @config{qw/use_match template_extension/};

    $self->template(
        HTML::Mason::Interp->new(
            %config,
            out_method => \$self->{output},
        )
    );

    return $self;
}

=head2 process

Renders the component specified in $c->stash->{template} or $c->request->match
or $c->action (depending on the use_match setting) to $c->response->body.

Note that the component name must be absolute, or is converted to absolute
(i.e., a / is added to the beginning if it doesn't start with one).

Mason global variables C<$base>, C<$c>, and C<$name> are automatically
set to the base, context, and name of the app, respectively.

=cut

sub process {
    my ($self, $c) = @_;

    my $component_path = $c->stash->{template};
    
    unless ($component_path) {
        $component_path = $self->config->{use_match}
            ? $c->request->match
            : $c->action;

        $component_path .= $self->config->{template_extension};
    }

    my $output = $self->render($c, $component_path);

    if (blessed($output) && $output->isa('HTML::Mason::Exception')) {
        chomp $output;
        my $error = qq/Couldn't render component "$component_path" - error was "$output"/;
        $c->log->error($error);
        $c->error($error);
        return 0;
    }

    unless ($c->response->content_type) {
        $c->response->content_type('text/html; charset=utf-8');
    }

    $c->response->body($output);

    return 1;
}

=head2 render($c, $component_path, \%args)

Renders the given template and returns output, or a HTML::Mason::Exception
object upon error.

The template variables are set to %$args if $args is a hashref, or
$c-E<gt>stash otherwise.

=cut

sub _default_globals {
    my ($self, $c) = @_;

    my %default_globals = (
        '$c'    => $c,
        '$base' => $c->request->base,
        '$name' => $c->config->{name},
    );

    return %default_globals;
}

sub render {
    my ($self, $c, $component_path, $args) = @_;

    if ($component_path !~ m{^/}) {
        $component_path = '/' . $component_path;
    }

    $c->log->debug(qq/Rendering component "$component_path"/) if $c->debug;

    # Set the URL base, context and name of the app as global Mason vars
    # $base, $c and $name
    my %default_globals = $self->_default_globals($c);
    while (my ($key, $val) = each %default_globals) {
        $self->template->set_global($key => $val);
    }

    $self->{output} = q//;

    eval {
        $self->template->exec(
            $component_path,
            ref $args eq 'HASH' ? %{ $args } : %{ $c->stash },
        );
    };

    if (my $error = $@) {
        return $error;
    }

    return $self->{output};
}

=head3 config

This allows you to to pass additional settings to the HTML::Mason::Interp
constructor or to set the options as below:

=over

=item C<use_match>

Use C<$c-E<gt>request-E<gt>match> instead of C<$c-E<gt>action> to determine
which template to use if C<$c-E<gt>stash-E<gt>{template}> isn't set. This option
is deprecated and exists for backward compatibility only.

Currently defaults to 1.

=back

The default HTML::Mason::Interp config options are as follows:

=over

=item C<comp_root>

C<$c-E<gt>config-E<gt>root>

=item C<data_dir>

C<File::Spec-E<gt>tmpdir>

=item C<allow_globals>

C<qw/$c $name $base/>

If you add additional allowed globals those will be appended to the list of
default globals.

=back

=cut

=head1 SEE ALSO

L<Catalyst>, L<HTML::Mason>, "Using Mason from a Standalone Script" in L<HTML::Mason::Admin>

=head1 AUTHOR

Andres Kievsky C<ank@cpan.org>
Sebastian Riedel C<sri@cpan.org>
Marcus Ramberg
Florian Ragwitz <rafl@debian.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
