# Copyright (C) 2009,2010 Róbert Viðar Bjarnason
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module PortalHelper
  def default_portal_update(portal_html,portal_container, admin)
    page<<"jQuery('#main-portal-div').html('#{portal_html}');"
    page << "setup_columns();"
  end

  def setup_priorities_three_newest
    @priorities=Priority.published.three.newest
    {:page_title=>t('priorities.newest.title', :target => current_government.target), 
     :priorities=>@priorities, :endorsements=>get_endorsements}
  end

  def setup_priorities_three_top
    @priorities=Priority.published.three.top_rank
    {:page_title=>t('priorities.top.title', :target => current_government.target), 
     :priorities=>@priorities, :endorsements=>get_endorsements}
  end

  def get_endorsements
    endorsements = nil
    if logged_in? # pull all their endorsements on the priorities shown
      endorsements = current_user.endorsements.active.find(:all, :conditions => ["priority_id in (?)", @priorities.collect {|c| c.id}])
    end
    endorsements
  end
end
