# Rails i18n Bundle #
by Ryan Stout
http://www.agileproductions.com/

## About ##

I did fine another Rails bundle that had i18n helpers, but none of them worked how I wanted them to, so I started over.

To make things easy, everything is based on using a default locale (english by default, which can be changed in Support/lib/config.rb)  It also assumes the location of the english file is config/locales/en.yml

Read more about rails i18n here: http://guides.rubyonrails.org/i18n.html

## Requirements ##

This bundle requires httparty, ruby-hmac, and ya2yaml to use.

	sudo gem install httparty ruby-hmac ya2yaml
	
It should work with ruby 1.8.7 or 1.9

## Install ##
To Install:

	mkdir -p ~/Library/Application\ Support/TextMate/Bundles
	cd ~/Library/Application\ Support/TextMate/Bundles
	git clone git://github.com/ryanstout/rails_i18n.tmbundle.git "Rails i18n.tmbundle"
	osascript -e 'tell app "TextMate" to reload bundles'

## Issues when showing ##

The yml files dumped out of this bundle should be in UTF-8.  In the event you get issues when displaying them in rails, be sure that your default external encoding is set to utf-8.  The easiest way to do this is placing this at the top of the environment.rb file.

	if RUBY_VERSION > "1.9"
	  Encoding.default_external = Encoding::UTF_8
	end

### Add to Locale ###

Select a section of text and hit CMD+SHIFT+I, this will then ask you for the token that identifies this string.  By default the bundle will use the controller and view as prefixes on the location of the string.  A shortcut for this is in rails a . in-front of the token, which will be automatically inserted before the token.  So inserted tokens will look like:

	<%= t('.your_token') %>

### Calculate Cost ###

The bundle has support for mygengo.com translation api.  Clicking on the calculate cost will give you a ESTIMATE of how much it will cost to translate your default locale into another language at the various qualities of mygengo.com

### Translate to Locale ###

Hitting CMD+SHIFT+G will ask you what locale you want to translate the default locale into.  You will then be asked how you want to translate the locale.  It will then loop through every string and translate the strings using the selected service.  Strings with existing translations will not be translated.

If you use google translate, translations will come back immediately.

The first time you choose to use MyGengo, you will be asked for your api_key and private_key

If you use *MyGengo.com*, you will be asked if you want translation jobs to be auto approved, if you choose no you will have to go onto mygengo.com and approve all strings.  When translating with mygengo.com, a placeholder will be inserted, then you can go to the bundle menu and select "Pull in MyGengo Translations" at a later point to pull in any finished translations.  You can do this as many times as is required.


