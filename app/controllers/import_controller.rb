require 'digest/sha1'
require 'load_google_contacts'
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
