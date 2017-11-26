package AcidWorx::API;

use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::Email;
use Dancer2::Plugin::Auth::Extensible;

use v5.20;
use AcidWorx::Email;
use AcidWorx::Link;
use AcidWorx::File;

use Data::Dumper qw(Dumper);

our $VERSION = '0.1';

set serializer => 'JSON';

get '/' => sub {
	return {test => 1, test2 => 2};
};

get '/confirm_email_send/:token/:email/:name' => sub {
	
	my $name = params->{ 'name' };

	my $acidworx_email = AcidWorx::Email->new(
		dbh => database,
		token => params->{ 'token' },
		email => params->{ 'email' },
	);

	warn Dumper $acidworx_email;


	my $template = Text::Template->new(
		TYPE => 'FILE',  
		SOURCE => config->{appdir} ."/views/confirm_email.tt",
	) or die $!;

	my $msg = $template->fill_in ( HASH => {
    	name => $name,
    	code => $acidworx_email->confirm_code,
    });

	email {
		from => 'no-reply@acidworx.com',
		to => $acidworx_email->email,
		subject => 'Please confirm your email',
		body => $msg,
	};

	return {status => 'ok'};

};

get '/confirm_email/:token/:code' => sub {

	my $acidworx_email = AcidWorx::Email->new(
		dbh => database,
		token => params->{ 'token' },
		confirm_code => params->{ 'code' },
	);

	if ( $acidworx_email->vaild_confirm_code ) {
		$acidworx_email->delete;
		return {status => 'ok'};
	} else {
		return {error => 'invalid code ' . params->{ 'code' }};
	}

};

get '/demo/remove-file/:filename' => require_login sub {
	my $demo_session = session 'demo';

	my $demo_files = $demo_session->{ 'files' };

	my @files_buffer;

	my $file_count = int @$demo_files;

	for my $file (@$demo_files) {
		warn "file_count: $file_count --  Checking file " . Dumper ($file);
    	if (params->{ 'filename' } ne $file->{ 'filename' }) {
    		push @files_buffer, $file;
    	} else {
    		# remove file from disk and database.
    		unlink $file->{ 'path' }
    			if -e $file->{ 'path' };
    		warn "*** removing file $file->{'path'}";
    		
    		my @path = split '/', $file->{ 'path' };
    		my $parent_dir = join '/', @path[0 .. ($#path - 1)];
			
			if ($file_count == 1 and -e $parent_dir) {
				warn "** removing path $parent_dir\n";
    			rmdir $parent_dir;
    		}
    		

    		my $file = AcidWorx::File->new(
		 		'token' => $demo_session->{ 'token' },
		 		'filename' => params->{ 'filename' },
		 		'dbh' => database,
		 	);

		 	$file->remove;
    	}
	}

	$demo_session->{ 'files' } = \@files_buffer;

	session 'demo' => $demo_session;

	return {status => 'ok'};
};


get '/demo/add-link/:token/:link' => sub {
	my $link = AcidWorx::Link->new(
 		'token' => params->{ 'token' },
 		'link' => params->{ 'link' },
 		'dbh' => database,
 	);

 	$link->add;

	return { status => 'ok' };
};

get '/demo/remove-link/:token/:link' => sub {
	my $link = AcidWorx::Link->new(
 		'token' => params->{ 'token' },
 		'link' => params->{ 'link' },
 		'dbh' => database,
 	);

 	$link->remove;

	return { status => 'ok' };
};


true;
