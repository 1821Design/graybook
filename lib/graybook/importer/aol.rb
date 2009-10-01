require 'graybook/importer/page_scraper'

##
# Imports contacts from AOL

class Graybook::Importer::Aol < Graybook::Importer::PageScraper

  ##
  # Matches this importer to an user's name/address

  def =~( options )
    options && options[:username] =~ /@(aol|aim)\.com$/i ? true : false
  end

  ##
  # Login process:
  # - Get mail.aol.com which redirects to a page containing a javascript redirect
  # - Get the URL that the javascript is supposed to redirect you to
  # - Fill out and submit the login form
  # - Get the URL from *another* javascript redirect

  def login
    page = agent.get( 'http://webmail.aol.com/' )

    form = page.forms.find{|form| form.name == 'AOLLoginForm'}
    form.loginId = options[:username].split('@').first # Drop the domain
    form.password = options[:password]
    page = agent.submit(form, form.buttons.first)

    case page.body
    when /Invalid Screen Name or Password. Please try again./
      return Problem.new("Username and password were not accepted. Please check them and try again.")
    when /Terms of Service/
      return Problem.new("Your AOL account is not setup for WebMail. Please signup: http://webmail.aol.com")
    end

    # aol bumps to a wait page while logging in.  if we can't scrape out the js then its a bad login
    extractor = proc { |var_name| page.body.scan(/var\s*#{var_name}\s*=\s*\"(.*?)\"\s*;/).first.first }

    base_uri = extractor.call( 'gSuccessPath' )
    return Problem.new("An error occurred. Please try again.") unless base_uri
    page = agent.get base_uri
  end

  ##
  # must login to prepare

  def prepare
    login
  end

  ##
  # The url to scrape contacts from has to be put together from the Auth cookie
  # and a known uri that hosts their contact service. An array of hashes with
  # :name and :email keys is returned.

  def scrape_contacts
    unless auth_cookie = agent.cookies.find{|c| c.name =~ /^Auth/}
      return Problem.new("An error occurred. Please try again.")
    end

    # jump through the hoops of formulating a request to get printable contacts
    uri = agent.current_page.uri.dup
    inputs = agent.current_page.search("//input")
    user = inputs.detect{|i| i['type'] == 'hidden' && i['name'] == 'user'}
    utoken = user['value']

    path = uri.path.split('/')
    path.pop
    path << 'addresslist-print.aspx'
    uri.path = path.join('/')
    uri.query = "command=all&sort=FirstLastNick&sortDir=Ascending&nameFormat=FirstLastNick&user=#{utoken}"
    page = agent.get uri.to_s

    # Grab all the contacts
    names = page.body.scan( /<span class="fullName">([^<]+)<\/span>/ ).flatten
    emails = page.body.scan( /<span>Email 1:<\/span> <span>([^<]+)<\/span>/ ).flatten
    (0...[names.size,emails.size].max).collect do |i|
      {
        :name => names[i],
        :email => emails[i]
      }
    end
  end

  Graybook.register :aol, self
end
