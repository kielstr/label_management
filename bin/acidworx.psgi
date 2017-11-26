#!/usr/bin/env perl

use v5.20;

use Plack::Builder;
use Plack::Middleware::ReverseProxy;
use Plack::Middleware::ReverseProxyPath;

use FindBin;
use lib "$FindBin::Bin/../lib";

use AcidWorx::WWW;
use AcidWorx::API;

builder {

	enable "ReverseProxy";
	enable "ReverseProxyPath";

    #enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } "Plack::Middleware::ReverseProxy";
    #enable 'Plack::Middleware::ReverseProxy';

    mount '/' => AcidWorx::WWW->to_app;
    mount '/api' => AcidWorx::API->to_app;
};

