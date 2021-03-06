#!/usr/bin/env perl6
use lib <lib>;

use IRC::Client;
use Buggable::Config;
use Buggable::Plugin::TravisWatcher;
use Buggable::Plugin::RT;
use Buggable::Plugin::Eco;
use Buggable::Plugin::Speed;
use Buggable::Plugin::Win;
use Buggable::Plugin::Toast;
use Buggable::Plugin::CPANTesters;
use Number::Denominate;

class Buggable::Info {
    multi method irc-to-me ($ where /^\s* help \s*$/) {
        "\x[2]tags\x[2] | \x[2]tag SOMETAG\x[2] | \x[2]eco\x[2] | "
            ~ "\x[2]eco\x[2] Some search term | \x[2]author\x[2] "
            ~ "github username | \x[2]speed\x[2] | \x[2]testers\x[2] "
            ~ "CPANTesters report ID";
    }
    multi method irc-to-me ($ where /^\s* source \s*$/) {
        "See: https://github.com/zoffixznet/perl6-buggable";
    }

    multi method irc-to-me ($ where /'bot' \s* 'snack'/) { "om nom nom nom"; }
}

.run with IRC::Client.new:
    :nick<buggable>,
    :username<zofbot-buggable>,
    :host(%*ENV<BUGGABLE_IRC_HOST> // 'irc.freenode.net'),
    :channels( %*ENV<BUGGABLE_DEBUG> ?? '#zofbot' !! |<#perl6  #perl6-dev  #zofbot  #moarvm>),
#    |(:password(conf<irc-pass>)
 #       if conf<irc-pass> and not %*ENV<BUGGABLE_DEBUG>
  #  ),
    :debug,
    :plugins(
        Buggable::Info.new,
        Buggable::Plugin::TravisWatcher.new,
        Buggable::Plugin::RT.new,
        Buggable::Plugin::Eco.new,
        Buggable::Plugin::Toast.new,
        Buggable::Plugin::Speed.new,
        Buggable::Plugin::Win.new(db => (
          (conf<win-db-file> || die 'Win lottery database file is missing').IO
        )),
        Buggable::Plugin::CPANTesters.new,
        class {
            multi method irc-to-me (
                $e where /:i ^ 6 \.? d '?'? \s* $ /
            ) {
                "¯\\_(ツ)_/¯"
                #"I think 6.d Diwali will be released in about "
                #~ denominate Date.new('2017-10-19').DateTime - DateTime.now
            }
        }
    );
