class FacebookController < ApplicationController

  before_filter :login_required
  protect_from_forgery :except => :multiple

  def invite
    @page_title = tr("Invite your Facebook friends to join {government_name}", "controller/facebook", :government_name => tr(current_government.name,"Name from database"))
    @user = User.find(current_user.id)
    @facebook_contacts = @user.contacts.active.facebook.collect{|c|c.facebook_uid}
    if current_facebook_user
      app_users = facebook_session.user.friends
      if app_users.any?
        count = 0
        @users = User.active.find(:all, :conditions => ["facebook_uid in (?)",app_users.collect{|u|u.uid}.uniq.compact])
        for user in @users
          unless @facebook_contacts.include?(user.facebook_uid)
            count += 1
            current_user.follow(user)
            @facebook_contacts << user.facebook_uid
          end
        end
      end
    end
  end

  # POST /facebook/multiple
  def multiple
    params[:ids] =["1595107152", "100001761113288"] # HACK TO TEST
    @user = User.find(current_user.id)
    if not params[:ids]
      redirect_to :controller => "network", :action => "find"
      return
    end
    @fb_users = current_facebook_user.friends
    success = 0
    @fb_users.each do |fb_user|
      next unless params[:ids].include?(fb_user.uid.to_s)
      @contact = @user.contacts.create(:name => fb_user.name, :facebook_uid => fb_user.uid, :is_from_realname => 1)
      if @contact
        success += 1
        @contact.invite!
        @contact.send!
      end
    end
    if success > 0
      flash[:notice] = tr("Invited {number} of your Facebook friends", "controller/facebook", :number => success)
    end
    redirect_to invited_user_contacts_path(current_user)
  end
  
end
