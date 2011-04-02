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
  def authenticate_google
    # create url with url-encoded params to initiate connection with contacts api
    # next - The URL of the page that Google should redirect the user to after authentication.
    # scope - Indicates that the application is requesting a token to access contacts feeds.
    # secure - Indicates whether the client is requesting a secure token.
    # session - Indicates whether the token returned can be exchanged for a multi-use (session) token.
    next_param = 'http://' + Government.current.base_url + '/import/authorise_google'
    scope_param = "https://www.google.com/m8/feeds/"
    session_param = "1"
    root_url = "https://www.google.com/accounts/AuthSubRequest"
    query_string = "?scope=#{scope_param}&session=#{session_param}&next=#{next_param}"
    session[:google_import_partner_id] = Partner.current.id if Partner.current
    redirect_to root_url + query_string
  end
   
  def authorise_google
    Partner.current = Partner.find(session[:google_import_partner_id]) if session[:google_import_partner_id]
    token = params[:token]
    Rails.logger.debug("Before https")
    uri = URI.parse("https://www.google.com")
    http = Net::HTTP.new(uri.host, uri.port)
    cert = File.read(Rails.root.join("config/yrprirsacert.pem"))
    pem = File.read(Rails.root.join("config/yrprirsakey.pem"))
    http.use_ssl = true 
    http.cert = OpenSSL::X509::Certificate.new(cert) 
    http.key = OpenSSL::PKey::RSA.new(pem) 
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER 
    path = '/accounts/AuthSubSessionToken'
    headers = {'Authorization' => "AuthSub token=#{token}"}
    Rails.logger.debug("After https setup")
    resp, data = http.get(path, headers)
    Rails.logger.debug(resp)
    Rails.logger.debug(data)
    if resp.code == "200"
      token = ''
      data.split.each do |str|
        if not (str =~ /Token=/).nil?
          token = str.gsub(/Token=/, '')
        end
      end
      Rails.logger.debug("Before redirect to import")
      return redirect_to(:host=>Government.current.base_url_w_partner, :action => 'import_google', :token => token)
    else
      Rails.logger.error("Authorise_google failed")
      redirect_to :action => "find", :controller=>"network", :host=>Government.current.base_url_w_partner, :notice => tr("Importing your gmail contacts failed.","import")
    end
  end
   
  def import_google
    @user = User.find(current_user.id)
    @user.is_importing_contacts = true
    @user.imported_contacts_count = 0
    @user.save(:validate => false)

    UserContact.delay.import_google(params[:token],@user.id)
    redirect_to :action => "import_status"
  end

  def import_status
    @page_title = tr("Importing your contacts", "controller/import")
    respond_to do |format|
      if not current_user.is_importing_contacts?
        flash[:notice] = tr("Finished loading contacts", "controller/import")
        if current_user.contacts_members_count > 0
          format.html { redirect_to members_user_contacts(current_user.id) }
          format.js { redirect_from_facebox(members_user_contacts(current_user.id)) }
        else
          format.html { redirect_to "users/#{current_user.to_param}/user_contacts/not_invited" }
          format.js { redirect_from_facebox "users/#{current_user.to_param}/user_contacts/not_invited" }
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
