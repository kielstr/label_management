package AcidWorx::WWW;

use v5.20;

use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::Email;
use Dancer2::Plugin::Auth::Extensible;
use Crypt::SaltedHash;

use Text::Template;
use FindBin qw( $RealBin );

use AcidWorx::Utils;
use AcidWorx::Artist;
use AcidWorx::Demo;
use AcidWorx::File;
use AcidWorx::Management::Demos;
use AcidWorx::Management::Artists;

use Data::Dumper qw(Dumper);

our $VERSION = '0.1';

my $user;
my $json;

hook before => sub {
	$user = logged_in_user;
	$json = to_json({
		profileImg => $user->{ 'image' },
	});
};

get '/' => require_login sub {
	
    template 'index', {
    	'page_title' => 'Management',
    	'profile_image' => $user->{ 'image' },
    	'JSON' => $json,
    };
};

# Artist Management 

get '/manage_artists/display' => require_role Admin => sub {
	my $artists_obj = AcidWorx::Management::Artists->new(
		'dbh' => database,
	);

	template 'manage_artists/select_artist', {
		'page_title' => 'Display Artist',
		'artists' => $artists_obj->get_artists,
		'back_url' => '/manage_artists',
		'action' => '/manage_artists/display',
		'JSON' => $json,
	};
};

post '/manage_artists/display' => require_role Admin => sub {

	my $artist_id = param( 'artist' );

	my $artist = AcidWorx::Artist->new(
		'dbh' => database,
		'artist_id' => $artist_id,
	);

	session 'artist' => {
		'name' => $artist->name,
		'artist_name' => $artist->artist_name,
		'address' => $artist->artist_name,
		'address_line1' => $artist->address_line1,
		'address_line2' => $artist->address_line2,
		'address_line3' => $artist->address_line3,
		'country_id' => $artist->country_id,
		'email' => $artist->email,
		'payment_email' => $artist->payment_email,
		'soundcloud_url' => $artist->soundcloud_url,
		'ra_url' => $artist->ra_url,
		'beatport_url' => $artist->beatport_url,
		'facebook_page' => $artist->facebook_page,
		'website' => $artist->website,
		'bio' => $artist->bio,
		'email_confirmed' => $artist->email_confirmed,
	};

	template 'manage_artists/display_artist', {
		'back_url' => '/manage_artists/display',
		'page_title' => 'Display Artist',
		'JSON' => $json,
	};
};

get '/manage_artists/edit' => require_role Admin => sub {
	my $artists_obj = AcidWorx::Management::Artists->new(
		'dbh' => database,
	);

	template 'manage_artists/select_artist', {
		'page_title' => 'Edit Artist',
		'artists' => $artists_obj->get_artists,
		'back_url' => '/manage_artists',
		'action' => '/manage_artists/edit',
		'JSON' => $json,
	};
};

post '/manage_artists/edit' => require_role Admin => sub {

	my $artist_id = param( 'artist' );
	my $update = param( 'update' );

	if ( $artist_id ) {
		my $artist = AcidWorx::Artist->new(
			'dbh' => database,
			'artist_id' => $artist_id,
		);

		$artist->populate_countries;

		my $country_aref = $artist->countries;

		session 'artist' => {
			'name' => $artist->name,
			'artist_name' => $artist->artist_name,
			'address' => $artist->artist_name,
			'address_line1' => $artist->address_line1,
			'address_line2' => $artist->address_line2,
			'address_line3' => $artist->address_line3,
			'country_id' => $artist->country_id,
			'email' => $artist->email,
			'payment_email' => $artist->payment_email,
			'soundcloud_url' => $artist->soundcloud_url,
			'ra_url' => $artist->ra_url,
			'beatport_url' => $artist->beatport_url,
			'facebook_page' => $artist->facebook_page,
			'website' => $artist->website,
			'bio' => $artist->bio,
			'email_confirmed' => $artist->email_confirmed,
		};

		return template 'artist', {
			'page_title' => 'Edit Artist',
			'countries' => $country_aref,
			'mode' => 'edit',
			'action' => '/manage_artists/edit',
			'back_url' => '/manage_artists/edit',
			'JSON' => $json,
		};

	} elsif ( $update ) {
		my $params = params;
		#session 'artist' => {} unless session( 'artist' );

		for my $param ( keys %$params ) {
			session( 'artist' )->{ $param } = $params->{ $param };
		}

		my $artist = AcidWorx::Artist->new(
			params,
			dbh => database,
		);

		# populate token after creating the object so we don't self populate.
		#$artist->token( session( 'artist' )->{ 'token' } );

		if ( $artist->error ) {
			my $errors = $artist->errors;

			warn Dumper $errors;

			$artist->populate_countries;

			my $country_aref = $artist->countries;

			template 'artist', {
				'page_title' => 'Edit artist',
				'errors' => "Please enter all the required fields",
				'countries' => $country_aref,
				'action' => '/new_artist',
				'mode' => 'new_artist',
				'back_url' => '/new_artist',
				'JSON' => $json,
			};
		} else {
			$artist->save;
			redirect '/manage_artists';
		}
	}
};

get '/manage_artists/add' => require_role Admin => sub {
	session 'artist' => {};

	my $artist = AcidWorx::Artist->new(
		'dbh' => database,
	);

	$artist->populate_countries;

	my $country_aref = $artist->countries;

	template 'artist', {
		'page_title' => 'Add Artist',
		'countries' => $country_aref,
		'mode' => 'add',
		'action' => '/manage_artists/add',
		'back_url' => '/manage_artists',
		'JSON' => $json,
	};
};

post '/manage_artists/add' => sub {
	my $params = params;
	#session 'artist' => {} unless session( 'artist' );

	for my $param ( keys %$params ) {
		session( 'artist' )->{ $param } = $params->{ $param };
	}

	my $artist = AcidWorx::Artist->new(
		params,
		dbh => database,
	);

	if ( $artist->error ) {
		my $errors = $artist->errors;

		$artist->populate_countries;

		my $country_aref = $artist->countries;

		template 'artist', {
			'page_title' => 'Add Artist',
			'errors' => "Please enter all the required fields",
			'countries' => $country_aref,
			'action' => '/manage_artists/add',
			'mode' => 'add',
			'back_url' => '/manage_artists',
			'JSON' => $json,
		};

	} else {

		$artist->save;

		redirect '/manage_artists';
	}
};

get '/manage_artists' => require_role Admin => sub {
	template 'manage_artists', {
		'page_title' => 'Manage Artists',
		'back_url' => '/',
		'JSON' => $json,
	};
};

post '/manage_artists/new_requests' => require_role Admin => sub {
	my $params = params;

	my $artists = AcidWorx::Management::Artists->new(
		'dbh' => database,
	);

	if ( $params->{ 'approve' } ) {
		
		my $template = Text::Template->new(
			TYPE => 'FILE',  
			SOURCE => "$RealBin/../views/artist_approval.tt"
		) or die $!;

		my @approved;

		if ( ref $params->{ 'approve' } ) {
			@approved = @{ $params->{ 'approve' } }
		} else {
			push @approved, $params->{ 'approve' };
		}

		for my $token ( @approved ) {

			$artists->approve_by_token( $token );

			my $artist = AcidWorx::Artist->new (
				'token' => $token,
				'dbh' => database,
			);

			my $msg = $template->fill_in( HASH => {
        		'name' => $artist->name,
        	});

			email {
	            'from'    => 'no-reply@acidworx.com',
	            'to'      => $artist->email,
	            'subject' => 'Welcome to AcidWorx',
	            'body'    => $msg,
	            #attach  => '/path/to/attachment',
	        };
		}

		$artists->get_new_request;
	}

	template 'manage_artists/new_requests', {
		'page_title' => 'Manage Artists',
		'back_url' => '/manage_artists',
		'new_requests' => $artists->new_request,
		'JSON' => $json,
	};
};

get '/manage_artists/new_requests' => require_login sub {
	my $artists = AcidWorx::Management::Artists->new(
		'dbh' => database,
	);

	$artists->get_new_request;

	template 'manage_artists/new_requests', {
		'back_url' => '/manage_artists',
		'page_title' => 'New Artist Requests',
		'new_requests' => $artists->new_request,
		'JSON' => $json,
	};
};

# Demo management

get '/manage_demos' => require_role Admin => sub {
		template 'manage_demos/manage_demos', {
			'page_title' => 'Demos',
			'back_url' => '/',
			'JSON' => $json,
		};
};

get '/manage_demos/new_demos' => require_role Admin => sub {
	my $demos = AcidWorx::Management::Demos->new(
		dbh => database,
	);

	template 'manage_demos/demos', {
		'page_title' => 'Manage Demos',
		'back_url' => '/manage_artists',
		'demos' => $demos->all_demos,
		'JSON' => $json,
	}
};

post '/manage_demos/new_demos' => require_role Admin => sub {
	
	my $params = params;
	my $approved;

	my $demos = AcidWorx::Management::Demos->new(
		dbh => database,
		dont_populate => 1,
	);

	my $template = Text::Template->new(
		TYPE => 'FILE',  
		SOURCE => "$RealBin/../views/demo_approval.tt"
	) or die $!;

	for my $key ( keys %$params ) {
		if ( $key =~ /^approve_/) {
			my (undef, $token) = split '_', $key;
			
			$demos->set_approval( $token, $params->{$key} );
			
			if ( $params->{$key} == 1 ) {

				my $demo = AcidWorx::Demo->new (
					'token' => $token,
					'dbh' => database,
				);

				my $msg = $template->fill_in ( HASH => {
		        	'name' => $demo->name,
		        	'link' => "http://acidworx.zapto.org/new_artist?token=$token",
		        });

				email {
		            'from'    => 'no-reply@acidworx.com',
		            'to'      => $demo->email,
		            'subject' => 'Demo to AcidWorx',
					'body'    => $msg,
		            #attach  => '/path/to/attachment',
		        };
			}
		}
	}

	$demos->populate;

	template '/manage_demos/demos', {
		'page_title' => 'Manage Demos',
		'back_url' => '/manage_artists',
		'demos' => $demos->all_demos,
		'JSON' => $json,
	}
};

# New Artist

get '/new_artist' => sub {

	my $token;

	session 'artist' => {} unless session( 'artist' );

	if ( param 'token' ) {
		$token = param 'token';
	} elsif ( cookie( 'artist' ) ) {
		$token = cookie( 'artist' )->value;
	}

	if ( $token ) {
		my $demo = AcidWorx::Demo->new (
			'token' => $token,
			'dbh' => database,
		);

		unless ( $demo->approved ) {
			return template 'new_artist_no_token';
		}

	} else {
		return template 'new_artist_no_token', {
			'page_title' => 'Sign Up',
		};
	}

	my $artist = AcidWorx::Artist->new(
		'dbh' => database,
	);

	$artist->populate_countries;

	my $country_aref = $artist->countries;

	if ( $token ) {
		my $demo = AcidWorx::Demo->new (
			'dbh' => database,
			'token' => ( $token ? $token : undef )
		);

		if ( $demo->token ) {
			session 'artist' => {
				'name' => $demo->name,
				'artist_name' => $demo->artist_name,
				'country_id' => $demo->country_id,
				'email' => $demo->email,
				'token' => $demo->token,
			};
		}
	}

	template 'artist', {
		'page_title' => 'Sign Up',
		'countries' => $country_aref,
		'action' => '/new_artist',
		'mode' => 'new_artist',
		'JSON' => $json,
	};
};

post '/new_artist' => sub {
	my $params = params;
	session 'artist' => {} unless session( 'artist' );

	my $artist_session = session( 'artist' );

	for my $param ( keys %$params ) {
		$artist_session->{ $param } = $params->{ $param };
	}

	my $artist = AcidWorx::Artist->new(
		params,
		dbh => database,
	);

	if ( $artist->error ) {
		my $errors = $artist->errors;

		$artist->populate_countries;

		my $country_aref = $artist->countries;

		session 'artist' => $artist_session;

		template 'artist', {
			'page_title' => 'Sign Up',
			'errors' => "Please enter all the required fields",
			'countries' => $country_aref,
			'action' => '/new_artist',
			'mode' => 'new_artist',
			'JSON' => $json,
		};

	} else {

		my @chars = ("A".."Z", "a".."z");
		my $code;
		$code .= $chars[rand @chars] for 1 .. 18;

		$artist_session->{ 'code' } = $code;

		my $template = Text::Template->new(
			TYPE => 'FILE',  
			SOURCE => "$RealBin/../views/confirm_email.tt"
		) or die $!;

		my $msg = $template->fill_in ( HASH => {
        	name => $artist->name,
        	code => $code,
        });

		email {
			from    => 'no-reply@acidworx.com',
			to      => $artist->email,
			subject => 'New artist sign up',
			body    => $msg,
		};

		$artist->save;

		cookie(
			'artist' => $artist->token, 
			'http_only' => 1, 
			'expires' => '-1'
		);

		session 'artist' => $artist_session;

		redirect '/new_artist_confirm_email';
	}
};

get '/new_artist_confirm_email' => sub {
	template 'new_artist_confirm_email', {
		'page_title' => 'Confirm Email',
		'JSON' => $json,
	};
};

post '/new_artist_confirm_email' => sub {
	my $params = params;

	my $artist = AcidWorx::Artist->new(
		'dbh' => database,
		'token' => ( cookies->{ 'artist' } and cookies->{ 'artist' }->value
				? cookies->{ 'artist' }->value : undef ) 
	);

	if ( $params->{ 'code' } eq session( 'artist' )->{ 'code' } ) {
		$artist->email_confirmed(1, 1);
	
		template 'new_artist_thankyou', {
			'page_title' => 'Thank You',
			'JSON' => $json,
		};
	} else {
		template 'new_artist_confirm_email', {
			'page_title' => 'Confirm Email',
			'errors' => ["Invalid code"],
			'JSON' => $json,
		};
	}
};

get '/new_artist_thankyou' => sub {
	template 'new_artist_thankyou', {
		'page_title' => 'Thank You',
		'JSON' => $json,
	};	
};

# Send demo

get '/demo' => sub {

	my $demo = AcidWorx::Demo->new (
		'dbh' => database,
	);

	my $page_session = session 'demo';

	if ( $page_session and $page_session->{'token'} ) {
		$demo->token( $page_session->{'token'} );
	} else {
		$demo->generate_token;
		$page_session->{ 'token' } = $demo->token;
	}

	$page_session->{ 'sent_to_other' } ||= 0;
	$page_session->{ 'send_by' } ||= 'link';
	$page_session->{ 'logged_in' } = ( $user->{ 'username' } ? 'true' : 'false' );
	
	session 'demo' => $page_session;

	$demo->populate_countries;

	template 'demo', {
		'page_title' => 'Send Demo',
		'countries' => $demo->countries,
		'JSON' => $json,
	};	
};

post '/demo' => sub {
	my $params = params;
	my $page_session = session 'demo';

	for my $param ( keys %$params ) {
		$page_session->{ ( $param eq 'send_by' ? 'sent_by' : $param ) } = $params->{ $param };
	}

	$page_session->{ 'sent_to_other' } ||= 0;

 	session 'demo' => $page_session;

 	if ( $params->{ 'send_by' } eq 'link' and not $params->{files} ) {
 		warn "No files sent in upload mode";
 	} else {

 	}

	my $demo = AcidWorx::Demo->new (
		'dbh' => database,
		%$page_session,
	);

	$demo->token( $page_session->{ 'token' } ) 
		if exists $page_session->{ 'token' };

	if ( $demo->error ) {
		my $errors = $demo->errors;

		$demo->populate_countries;

		my $country_aref = $demo->countries;

		template 'demo', {
			'page_title' => 'Send Demo',
			'errors' => "Please enter all the required fields",
			'countries' => $country_aref,
			'JSON' => $json,
		};

	} else {
		$demo->save;
		#session 'demo' => undef;

		# The token here will no longer work. rethink this !!
		cookie(
			'artist' => $demo->token, 
			'http_only' => 1, 
			'expires' => 'Fri, 31 Dec 9999 23:59:59 GMT'
		);

		redirect '/demo_thankyou';
	}
};

get '/demo_thankyou' => sub {
	session 'demo' => undef;
	template 'demo_thankyou', {
		'page_title' => 'Thank You',
		'JSON' => $json,
	};
};

# Upload file
get '/upload' => require_login sub {
	template 'upload', { 
		JSON => undef
	};
};

post '/upload' => require_login sub {
	my $params = params;
	my $page_session = session 'demo';

	my $data = request->upload( 'file' );
 
    my $dir = path('/acidworx/uploads/' . $page_session->{ 'token' } . '/');
    mkdir $dir if not -e $dir;

    my $path = path($dir, $data->basename) or die $!;
 	$data->copy_to($path) or die $!;

 	my $file = AcidWorx::File->new(
 		'token' => $page_session->{ 'token' },
 		'filename' => $data->basename,
 		'path' => $path,
 		'dbh' => database,
 	);

 	$file->add;

 	push @{ $page_session->{ 'files' } }, {
 		'token' => $page_session->{ 'token' },
 		'filename' => $data->basename,
 		'path' => $path,
 	};

 	session 'demo' => $page_session;
};

# Release Management

get 'manage_release' => require_role Admin => sub {
	template 'manage_release/index', {
		'page_title' => 'Manage Releases',
		'back_url' => '/',
		'JSON' => $json,
	};
};

get '/manage_release/add_track' => require_role Admin => sub {
	template 'manage_release/add_track', {
		'page_title' => 'Add Track',
		'mode' => 'add',
		'back_url' => '/manage_release',
		'JSON' => $json,
	};
};

get '/manage_release/edit_track' => require_role Admin => sub {
	template 'manage_release/add_track', {
		'page_title' => 'Add Track',
		'mode' => 'edit',
		'back_url' => '/manage_release',
		'JSON' => $json,
	};
};

get '/manage_release/remove_track' => require_role Admin => sub {
	template 'manage_release/add_track', {
		'page_title' => 'Add Track',
		'mode' => 'remove',
		'back_url' => '/manage_release',
		'JSON' => $json,
	};
};

get '/manage_release/show' => require_role Admin => sub {
	template 'manage_release/show', {
		'page_title' => 'Show Release',
		'back_url' => '/manage_release',
		'JSON' => $json,
	};
};

get '/manage_release/add' => require_role Admin => sub {

	my $artists_obj = AcidWorx::Management::Artists->new(
		dbh => database,
	);

	$artists_obj->get_artists;

	template 'manage_release/add', {
		'page_title' => 'Add Release',
		'artists' => $artists_obj->artists,
		'back_url' => '/manage_release',
		'JSON' => $json,
	};
};

# User Management

get '/user_management/add' => require_role Admin => sub {
	template 'user_management/user', {
		'page_title' => 'Add User',
		'back_url' => '/',
		'mode' => 'add',
		'JSON' => $json,
	};
};

post '/user_management/add' => require_role Admin => sub {
	my $params = params;
	
	my $file = $params->{ 'profile_image' };
	my $data = request->upload( 'profile_image' );
 
    my $dir = path(config->{appdir}, '/public/images/profile');
    mkdir $dir if not -e $dir;
 
    my $path = path($dir, $data->basename);

    $data->link_to($path);

	create_user (
		'username' => $params->{ 'username' }, 
		'email' => $params->{ 'email' }, 
		'email_welcome' => 1,
		'id' => undef,
		'image' => "/images/profile/$file",
	);

	template 'user_management/user', {
		'page_title' => 'Edit User',
		'back_url' => '/',
		'mode' => 'add',
		'JSON' => $json,
	};
};

get '/user_management/edit' => require_role Admin => sub {

	my $username = param( 'username' );

	if ( $username ) {

		my $user_details = get_user_details( $username );

		my $dir = path(config->{appdir}, '/public/images/profile');
			
		return template 'user_management/user', {
			'page_title' => 'Edit User',
			'back_url' => '/',
			'mode' => 'edit',
			'JSON' => $json,
			'user_details' => $user_details,
			'dir' => $dir,
		};

	} else {

		my $utils = AcidWorx::Utils->new(
			dbh => database,
		);

		my $all_users = $utils->all_users;

		return template 'user_management/select_user', {
			'page_title' => 'Select user',
			'back_url' => '/',
			'mode' => 'edit',
			'JSON' => $json,
			'all_users' => $all_users,
		};
	}	
};

post '/user_management/edit' => require_role Admin => sub {

	my $params = params;

	my $file = $params->{ 'profile_image' };

    my %update_details;

	if ( $file ) {
		my $data = request->upload( 'profile_image' );
 
	    my $dir = path(config->{appdir}, '/public/images/profile');
	    mkdir $dir if not -e $dir;
	 
	    my $path = path($dir, $data->basename);

	    $data->link_to($path);

	    $update_details{ 'image' } = "/images/profile/$file"
    		if $params->{ "profile_image" };

	}
	
    $update_details{ 'email' } = $params->{ "email" } 
    	if $params->{ "email" };

	update_user( $params->{ "username" }, %update_details )
		if $update_details{ 'image' } or $update_details{ 'email' };

	redirect '/';
};

get '/user_management/remove' => require_role Admin => sub {
	template 'user_management/user', {
		'page_title' => 'Remove User',
		'back_url' => '/',
		'mode' => 'remove',
		'JSON' => $json,
	};
};

post '/user_management/remove' => require_role Admin => sub {
	template 'user_management/user', {
		'page_title' => 'Remove User',
		'back_url' => '/',
		'mode' => 'remove',
		'JSON' => $json,
	};
};

# User change password

get '/user_management/change_password' => require_login sub {
	template 'user_management/change_password', {
		'page_title' => 'Change Password',
		'back_url' => '/',
		'JSON' => $json,
	};
};

post '/user_management/change_password' => require_login sub {
	my $params = params;

	if ( $params->{ 'password' } eq $params->{ 'password_confirm' }) {
	    user_password( 
	    	'username' => $user->{ 'username' }, 
	    	'new_password' => $params->{ 'password' } 
	    );
		redirect '/';
	} else {
		template 'user_management/change_password', {
			'page_title' => 'Change Password',
			'back_url' => '/manage_release',
			'errors' => "Passwords don't match",
			'JSON' => $json,
		};
	}
};

true;
