# Copyright (C) 2008,2009,2010 Róbert Viðar Bjarnason
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

module PriorityProcessesHelper
  def get_internal_process_documents_links(document)
    if document.original_version or document.user
      if document.original_version
        author = "<b>#{t(:see_and_vote_for_this_process_document_here)}</b>" #TODO: Remove hack
      elsif document.user
        author = "#{t(:author)}: #{document.user.login}"
      else
        author = "#{t(:author)}: unknown"
      end
      "#{link_to author, {:controller=>"process_documents", :action=>"show", :id=>document.id}, {:class=>"participateLinkLarger"}} <br>"
    end
  end
  
  def latest_video_speech_title(video)
    "#{t(:process)}: #{video.process_discussion.process.external_info_1} / #{video.process_discussion.stage_sequence_number}. #{t(:stage_sequence_discussion)}"
  end

  def latest_video_speech_description(video)
    "#{t(:process)}: #{video.process_discussion.process.external_info_1} (#{video.process_discussion.process.external_info_2}) / #{video.process_discussion.process.external_info_3} - #{video.process_discussion.stage_sequence_number}. #{t(:stage_sequence_discussion)}"
  end
end
