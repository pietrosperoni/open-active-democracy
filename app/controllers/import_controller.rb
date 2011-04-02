require 'digest/sha1'
require 'net/http'
require 'net/https'
require 'uri'

class ImportController < ApplicationController

  before_filter :login_required
  protect_from_forgery :except => :windows
  
  def google
    if not current_user.attribute_present?("google_token") and not params[:token]
      out_url = Contacts::Google.authentication_url(url_for(:only_path => false, :controller => "import", :action => "google"), :session => true)
      Rails.logger.debug("Google import #{out_url}")
      redirect_to out_url
      return
    elsif params[:token]
      token = Contacts::Google.session_token(params[:token])      
      current_user.update_attribute(:google_token,token)
    end
    Rails.logger.debug("IM HERE!!!!")
    @user = User.find(current_user.id)
    @user.is_importing_contacts = true
    @user.imported_contacts_count = 0
    @user.save(:validate => false)
    Delayed::Job.enqueue LoadGoogleContacts.new(@user.id), 5
    redirect_to :action => "import_status"
  end
  
  def yahoo
    if not request.request_uri.include?('token')
      redirect_to Contacts::Yahoo.new.get_authentication_url
      return
    end
    @user = User.find(current_user.id)
    @user.is_importing_contacts = true
    @user.imported_contacts_count = 0
    @user.save(:validate => false)
    Delayed::Job.enqueue LoadYahooContacts.new(@user.id,request.request_uri), 5
    redirect_to :action => "import_status"
  end  

  def windows
    if not request.post?
      redirect_to Contacts::WindowsLive.new.get_authentication_url 
      return
    end
    @user = User.find(current_user.id)
    @user.is_importing_contacts = true
    @user.imported_contacts_count = 0
    @user.save(:validate => false)
    Delayed::Job.enqueue LoadWindowsContacts.new(@user.id,request.raw_post), 5
    redirect_to :action => "import_status"    
  end

  # methods below from http://rtdptech.com/2010/12/importing-gmail-contacts-list-to-rails-application/
  #THIS METHOD TO SEND USER TO THE GOOGLE AUTHENTICATION PAGE.
  def authenticate
    # initiate authentication w/ gmail
    # create url with url-encoded params to initiate connection with contacts api
    # next - The URL of the page that Google should redirect the user to after authentication.
    # scope - Indicates that the application is requesting a token to access contacts feeds.
    # secure - Indicates whether the client is requesting a secure token.
    # session - Indicates whether the token returned can be exchanged for a multi-use (session) token.
    next_param = PLANNER_HOST.to_s + authorise_imported_contacts_path.to_s
    scope_param = "https://www.google.com/m8/feeds/"
    session_param = "1"
    root_url = "https://www.google.com/accounts/AuthSubRequest"
    #TO FIND MORE AOBUT THESE PARAMTERS AND TEHRE MEANING SEE GOOGLE API DOCS.
    query_string = "?scope=#{scope_param}&session=#{session_param}&next=#{next_param}"
    redirect_to root_url + query_string
  end
   
  # YOU WILL BE REDIRECTED TO THIS ACTION AFTER COMPLETION OF AUTHENTICATION PROCESS WITH TEMPORARY SINGLE USE AUTH TOKEN.
  def authorise
    #FIRST SINGEL USE TOKEN WILL BE RECEIVED HERE..
    token = params[:token]
    #PREPAIRING FOR SECOND REQUEST WITH AUTH TOKEN IN HEADER.. WHICH WILL BE EXCHANED FOR PERMANENT AUTH TOKEN.
    uri = URI.parse("https://www.google.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    path = '/accounts/AuthSubSessionToken'
    headers = {'Authorization' => "AuthSub token=#{token}"}
   
    #GET REQUEST ON URI WITH SPECIFIED PATH...
    resp, data = http.get(path, headers)
    #SPLIT OUT TOKEN FROM RESPONSE DATA.
    if resp.code == "200"
      token = ''
      data.split.each do |str|
      if not (str =~ /Token=/).nil?
        token = str.gsub(/Token=/, '')
      end
    end
  return redirect_to(:action => 'import', :token => token)
  else
  redirect_to root_url , :notice => "fail"
  end
  end
   
  #USING PERMANENT TOKEN IN THIS ACTION TO GET USER CONTACT DATA.
  def import
    # GET http://www.google.com/m8/feeds/contacts/default/base
    token = params[:token]
    uri = URI.parse("https://www.google.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    path = "/m8/feeds/contacts/default/full?max-results=10000"
    headers = {'Authorization' => "AuthSub token=#{token}",
    'GData-Version' => "3.0"}
    resp, data = http.get(path, headers)
    # extract the name and email address from the response data
    # HERE USING REXML TO PARSE GOOGLE GIVEN XML DATA
    xml = REXML::Document.new(data)
    contacts = []
    xml.elements.each('//entry') do |entry|
      person = {}
      person['name'] = entry.elements['title'].text
      gd_email = entry.elements['gd:email']
      person['email'] = gd_email.attributes['address'] if gd_email
      @imported_contact = current_user.imported_contacts.create(person)
    end
    
    redirect_to root_urL , :notice => "imported successfully"
  end

  def import_status
    @page_title = tr("Importing your contacts", "controller/import")
    respond_to do |format|
      if not current_user.is_importing_contacts?
        flash[:notice] = tr("Finished loading contacts", "controller/import")
        if current_user.contacts_members_count > 0
          format.html { redirect_to :action=>"members", :controller=>"user_contacts", :id=>current_user.id }
          format.js { redirect_from_facebox(:action=>"members", :controller=>"user_contacts", :id=>current_user.id) }
        else
          format.html { redirect_to :action=>"not_invited", :controller=>"user_contacts", :id=>current_user.id }
          format.js { redirect_from_facebox(:action=>"not_invited", :controller=>"user_contacts", :id=>current_user.id) }          
        end
      else
        format.html
        format.js {
          render :update do |page|        
            page[:number_completed].replace_html current_user.imported_contacts_count
          end
        }
      end
    end
  end
  
end
