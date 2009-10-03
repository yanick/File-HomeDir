package File::HomeDir::DarwinCocoa;

use 5.00503;
use strict;
use Cwd                 ();
use Carp                ();
use File::HomeDir::DarwinPerl ();
use Mac::SystemDirectory;

use vars qw{$VERSION @ISA};
BEGIN {
	$VERSION = '0.86';
	@ISA     = 'File::HomeDir::DarwinPerl';
}


#####################################################################
# Current User Methods

sub my_home {
    my ($class) = @_;

    # A lot of unix people and unix-derived tools rely on
    # the ability to overload HOME. We will support it too
    # so that they can replace raw HOME calls with File::HomeDir.
    if ( exists $ENV{HOME} and defined $ENV{HOME} ) {
        return $ENV{HOME};
    }

    $class->_find_folder(Mac::SystemDirectory::NSUserDirectory());
}

# from 10.4
sub my_desktop {
    my ($class) = @_;
    eval { $class->_find_folder(Mac::SystemDirectory::NSDesktopDirectory()) }
        || $class->SUPER::my_desktop;
}

# from 10.2
sub my_documents {
    my ($class) = @_;
    eval { $class->_find_folder(Mac::SystemDirectory::NSDocumentDirectory()) }
        || $class->SUPER::my_documents;
}

# from 10.4
sub my_data {
    my ($class) = @_;
    eval { $class->_find_folder(Mac::SystemDirectory::NSApplicationSupportDirectory()) }
        || $class->SUPER::my_data;
}

# from 10.6
sub my_music {
    my ($class) = @_;
    eval { $class->_find_folder(Mac::SystemDirectory::NSMusicDirectory()) }
        || $class->SUPER::my_music;
}

# from 10.6
sub my_pictures {
    my ($class) = @_;
    eval { $class->_find_folder(Mac::SystemDirectory::NSPicturesDirectory()) }
        || $class->SUPER::my_pictures;
}

# from 10.6
sub my_videos {
    my ($class) = @_;
    eval { $class->_find_folder(Mac::SystemDirectory::NSMoviesDirectory()) }
        || $class->SUPER::my_videos;
}

sub _find_folder {
    my ($class, $name) = @_;

    my $folder = Mac::SystemDirectory::FindDirectory($name);
    return unless defined $folder;

    unless ( -d $folder ) {
        # Make sure that symlinks resolve to directories.
        return unless -l $folder;
        my $dir = readlink $folder or return;
        return unless -d $dir;
    }
    return Cwd::abs_path($folder);
}

1;

=pod

=head1 NAME

File::HomeDir::DarwinCocoa - find your home and other directories, on Darwin (OS X)

=head1 DESCRIPTION

This module provides Darwin-specific implementations for determining
common user directories using Cocoa API through
L<Mac::SystemDirectory>.  In normal usage this module will always be
used via L<File::HomeDir>.

Note -- since this module requires Mac::SystemDirectory, if the module
is not installed, File::HomeDir will fall back to File::HomeDir::DarwinPerl.

=head1 SYNOPSIS

  use File::HomeDir;

  # Find directories for the current user
  $home    = File::HomeDir->my_home;      # /Users/mylogin
  $desktop = File::HomeDir->my_desktop;   # /Users/mylogin/Desktop
  $docs    = File::HomeDir->my_documents; # /Users/mylogin/Documents
  $music   = File::HomeDir->my_music;     # /Users/mylogin/Music
  $pics    = File::HomeDir->my_pictures;  # /Users/mylogin/Pictures
  $videos  = File::HomeDir->my_videos;    # /Users/mylogin/Movies
  $data    = File::HomeDir->my_data;      # /Users/mylogin/Library/Application Support

