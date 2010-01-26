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

  def setup_priorities_newest(limit)
    @priorities=Priority.published.newest.item_limit limit
    {:page_title=>t('priorities.newest.name'), :more=>newest_priorities_url,
     :priorities=>@priorities, :endorsements=>get_endorsements}
  end

  def setup_priorities_top(limit)
    @priorities=Priority.published.top_rank.item_limit limit
    {:page_title=>t('priorities.top.name'), :more=>top_priorities_url, 
     :priorities=>@priorities, :endorsements=>get_endorsements}
  end

  def setup_priorities_rising(limit)
    @priorities= Priority.published.rising.item_limit limit
    {:page_title=>t('priorities.rising.name'), :more=>rising_priorities_url,
     :priorities=>@priorities, :endorsements=>get_endorsements}
  end


  def setup_priorities_falling(limit)
    @priorities= Priority.published.falling.item_limit limit
    {:page_title=>t('priorities.falling.name'), :more=>falling_priorities_url,
     :priorities=>@priorities, :endorsements=>get_endorsements}
  end

  def setup_priorities_controversial(limit)
    @priorities= Priority.published.controversial.item_limit limit
    {:page_title=>t('priorities.controversial.name'), :more=>controversial_priorities_url,
     :priorities=>@priorities, :endorsements=>get_endorsements}
  end

  def setup_priorities_finished(limit)
    @priorities= Priority.published.finished.by_most_recent_status_change.item_limit limit
    {:page_title=>t('priorities.finished.name'), :more=>finished_priorities_url,
     :priorities=>@priorities, :endorsements=>get_endorsements}
  end

  def setup_priorities_random(limit)
    if User.adapter == 'postgresql'
      @priorities = Priority.published.paginate :order => "RANDOM()", :page => 1, :per_page => limit
    else
      @priorities = Priority.published.paginate :order => "rand()", :page => 1, :per_page => limit
    end
    {:page_title=>t('priorities.random.name'), :more=>random_priorities_url,
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
