# coding: utf-8

require './crawler_utils'

class ProcessParser

  @@stage_sequence_number = @@discussion_sequence_number = @@process_document_sequence_number = 0

  def self.get_stage_sequence_number(txt, process_type)
    if process_type == PROCESS_TYPE_LOG
      re1='(\\d+)'  # Integer Number 1
      re2='(\\.)' # Any Single Character 1
      re3='(\\s+)'  # White Space 1
      re4='(umræða)' # Word 1
      
      re=(re1+re2+re3+re4)
      m=Regexp.new(re,Regexp::IGNORECASE);
      if m.match(txt)
        int1=m.match(txt)[1];
      end
      
      return int1
    elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
      if txt=="Fyrri umræða"
        return 1
      elsif txt=="Síðari umræða"
        return 2
      end
    end
  end

  def self.process_documents(next_sibling,current_process,process_document_type,process_type)
    tr_count = 3
    while next_sibling.at("tr[#{tr_count}]/td[1]")
      process_document = ProcessDocument.new
      process_document.sequence_number=@@process_document_sequence_number+=1
      process_document.priority_process_id = current_process.id
      process_document.stage_sequence_number = @@stage_sequence_number
      process_document.external_date = DateTime.strptime(next_sibling.at("tr[#{tr_count}]/td[1]").text.strip, "%d.%m.%Y")
      puts "ProcessDocument date: #{process_document.external_date}"
      if next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")
        process_document.external_id = next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]").text.strip
        puts "ProcessDocument external id: #{process_document.external_id}"
        process_document.external_link = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")['href']
        puts "ProcessDocument url: #{process_document.external_link}"
      end
      if next_sibling.at("tr[#{tr_count}]/td[3]").text
        process_document.external_type = next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
        puts "ProcessDocument external type: #{process_document.external_type}"
      else
        puts "ProcessDocument external type unknown"
      end
      if next_sibling.at("tr[#{tr_count}]/td[4]").text
        process_document.external_author = next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
        puts "ProcessDocument author: #{process_document.external_author}"
      else
        puts "ProcessDocument author unknown"
      end

      if not ARGV.empty? and ARGV[0] == "force_refresh_on_document_parsing"
        oldpd = ProcessDocument.find_by_external_link(process_document.external_link)
        if oldpd
          oldpd.process_document_elements.each do |e|
            e.destroy
          end
          oldpd.destroy
        end
      end

      unless oldpd = ProcessDocument.find_by_external_link(process_document.external_link)
        if process_document.external_type =~ /frumvarp/i or process_document.external_type =~ /lög/i
            process_document.external_type =~ /þingsályktun/i or process_document.external_type =~ /stjórnartillaga/i
          document = LawProposalDocumentElement.create_elements(process_document, process_document.priority_process_id, process_document.id, process_document.external_link,process_type)
        else #TODO: Hack to get things saved
          document = LawProposalDocumentElement.create_elements(process_document, process_document.priority_process_id, process_document.id, process_document.external_link,process_type)
        end         

        if document
          unless old_process = PriorityProcess.find(:first, :conditions=>["priority_id = ? AND stage_sequence_number = ?",
                                                    current_process.priority_id, current_process.stage_sequence_number])
            current_process.save
          else
            current_process = old_process
          end
          puts "SAVING PROCESS DOCUMENT WITH PROCESS_ID = #{current_process.id}"
          process_document.priority_process_id = current_process.id
          process_document.process_document_type_id = process_document_type.id
          process_document.save
        end
      else
        puts "Found old ProcessDocument"
      end
      tr_count+=1
      puts ""
    end     
  end
  
  def self.process_discussion(next_sibling,current_process)
    tr_count = 3
    while next_sibling.at("tr[#{tr_count}]/td[1]")
      process_discussion = ProcessDiscussion.new
      process_discussion.sequence_number=@@discussion_sequence_number+=1
      process_discussion.priority_process_id = current_process.id
      process_discussion.stage_sequence_number = @@stage_sequence_number
      if next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0]
        date_from_time = next_sibling.at("tr[#{tr_count}]/td[1]").text.strip + " " + next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0].text.strip[0..4]
        puts "ProcessDiscussion from time: "+date_from_time
        date_to_time = next_sibling.at("tr[#{tr_count}]/td[1]").text.strip + " " + next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0].text.strip[6..10]
        puts "ProcessDiscussion to time: "+date_to_time
        puts "ProcessDiscussion SAME TIME" if date_from_time==date_to_time
        process_discussion.from_time = DateTime.strptime(date_from_time, "%d.%m.%Y %H:%M")
        process_discussion.to_time = DateTime.strptime(date_to_time, "%d.%m.%Y %H:%M")
        process_discussion.transcript_url="http://www.althingi.is"+next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0]['href']
        puts "ProcessDiscussion url: "+process_discussion.transcript_url
      end
      if next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[1]
        process_discussion.listen_url=next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[1]['href']
        puts "ProcessDiscussion listen url: "+process_discussion.listen_url
      end
      process_discussion.meeting_date = DateTime.strptime(next_sibling.at("tr[#{tr_count}]/td[1]").text.strip, "%d.%m.%Y")
      puts "ProcessDiscussion meeting date: #{process_discussion.meeting_date}"
      if next_sibling.at("tr[#{tr_count}]/td[3]").text
        process_discussion.meeting_type = next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
        puts "ProcessDiscussion meeting type: "+process_discussion.meeting_type
      else
        puts "ProcessDiscussion meeting type unknown"
      end
      if next_sibling.at("tr[#{tr_count}]/td[4]").text
        process_discussion.meeting_info = next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
        puts "ProcessDiscussion meeting info: "+process_discussion.meeting_info
        process_discussion.meeting_url = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[4]/a[@href]")['href'] if next_sibling.at("tr[#{tr_count}]/td[4]/a[@href]")
        puts "ProcessDiscussion meeting url: "+process_discussion.meeting_url
      else
        puts "ProcessDiscussion meeting number: unknown"
      end
      unless date_from_time==date_to_time
        unless oldpd = ProcessDiscussion.find(:first, :conditions => ["transcript_url = ?", process_discussion.transcript_url])
          unless old_process = PriorityProcess.find(:first, :conditions=>["priority_id = ? AND stage_sequence_number = ?",
                                                                           current_process.priority_id, current_process.stage_sequence_number])
            current_process.save
          else
            current_process = old_process
          end
          process_discussion.priority_process_id = current_process.id
          process_discussion.save
        else
          puts "Found old ProcessDiscussion"
        end
      end
      tr_count+=1
    end
  end
  
  def self.get_process(url, presenter, external_id, external_name, process_type)
    html_doc = CrawlerUtils.fetch_html(url)
    ur_params = CGI.parse(URI.parse(url).query)
    ltg = ur_params["ltg"].first
    mnr = ur_params["mnr"].first

    if process_type == PROCESS_TYPE_LOG
      info_2 = "#{mnr}. mál lagafrumvarp"
    elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
      info_2 = "#{mnr}. mál þingsályktunartillaga" 
    end
    info_3 = "#{ltg}. löggjafarþingi."

    if process_type == PROCESS_TYPE_LOG
      proposal_tag = "Law proposal"
      unless current_user = User.find_by_email("lagafrumvorp@ibuar.is")
        current_user=User.new
        current_user.email = "lagafrumvorp@ibuar.is"
        current_user.login = "Lagafrumvörp frá Alþingi"
        current_user.save(:validate => false)
      end
    elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
      proposal_tag = "Parliamentary resolution proposal"
      unless current_user = User.find_by_email("thingsalyktunartillaga@ibuar.is")
        current_user=User.new
        current_user.email = "thingsalyktunartillaga@ibuar.is"
        current_user.login = "Þingsályktunartillögur frá Alþingi"
        current_user.save(:validate => false)
      end
    end
    
    current_priority = Priority.new

    current_priority.external_info_1 = (html_doc/"h1.FyrirsognStorSv").text.strip
    current_priority.external_info_2 = info_2
    current_priority.external_info_3 = info_3
    current_priority.external_link = url
    current_priority.external_presenter = presenter
    current_priority.external_id = mnr
    current_priority.external_session_id = ltg
    current_priority.external_name = external_name
    current_priority.name = (html_doc/"h1.FyrirsognStorSv").text.strip
    current_priority.user = current_user
    current_priority.ip_address = "127.0.0.1"
    current_priority.category_id =

    placeholder_tag = nil
    if category_id = CrawlerUtils.get_process_category_id(mnr)
      current_priority.category_id = category_id
      puts "Process category_id: #{current_priority.category_id}"
    else
      current_priority.category_id = Category.find_or_create_by_name('Miscellaneous').id
      puts "Process category id unknown"
      placeholder_tag = Tag.find_or_create_by_name('Uncategorized proposals').name
    end

    primary_issues = [proposal_tag]
    primary_issues << placeholder_tag if placeholder_tag
    current_priority.issue_list = [[primary_issues] | CrawlerUtils.get_process_tag_names(mnr) | TagsParser.get_tags(html_doc)].join(',')
    puts "Process tags: #{current_priority.issue_list}"

    old_priority = Priority.find_by_external_id_and_external_session_id(mnr, ltg)
    if old_priority
      if old_priority.external_link != current_priority.external_link
        puts "UPDATING EXTERNAL LINK FOR OLD PRIORITY: #{old_priority.external_link}"
        old_priority.external_link = current_priority.external_link
      end

      old_tags     = old_priority.issue_list.to_a
      current_tags = current_priority.issue_list.to_a
      new_tags     = current_tags - old_tags

      unless new_tags.empty?
        puts "ADDING NEW TAGS TO OLD PRIORITY: #{new_tags}"
        combined_tags = old_tags | new_tags
        old_priority.issue_list = combined_tags.join(", ")
        old_priority.save(false)
      end

      current_priority = old_priority
    else
      current_priority.save(false)
    end

    unless process_type_record = ProcessType.find_by_process_type("Althingi Process")
      process_type_record = ProcessType.new
      process_type_record.process_type = "Althingi Process"
      process_type_record.template_name = "icelandic_parliament"
      process_type_record.save
    end
    
    unless process_document_type = ProcessDocumentType.find_by_process_document_type("Althingi Process")
      process_document_type = ProcessDocumentType.new
      process_document_type.process_document_type = "Althingi Process"
      process_document_type.template_name = "icelandic_parliament"
      process_document_type.save
    end
    
    @@stage_sequence_number = 0
    
    current_process = PriorityProcess.new
    current_process.process_type_id=process_type_record.id
    current_process.root_node = true
    current_process.parent_id = nil
    current_process.priority_id = current_priority.id
    current_process.process_type = ProcessType.find_by_process_type("Althingi Process")
    current_process.stage_sequence_number=@@stage_sequence_number+=1

    @@process_document_sequence_number = @@discussion_sequence_number = 0
    if (html_doc/"h2.FyrirsognMidSv").text==""
      next_sibling=html_doc.xpath('/html/body/table/tr[2]/td/table/tr/td[2]/div/table')
      puts "============"      
      puts next_sibling.at("tr[1]/td[1]").text
      puts "============"
      #@@stage_sequence_number = 0
      if next_sibling.at("tr[1]/td[1]").text=="Þingskjöl"
        process_documents(next_sibling,current_process,process_document_type,process_type)
      end
    else
     (html_doc/"h2.FyrirsognMidSv").each do |row|
        # Process stage_sequence
        #@@stage_sequence_number = get_stage_sequence_number(row.text.strip, process_type).to_i
        puts "Stage sequence number: #{@@stage_sequence_number} (#{row.text.strip})"
        next_sibling = row.next_sibling
        @@process_document_sequence_number = @@discussion_sequence_number = 0
        while next_sibling and next_sibling.to_s[0..3]!="<div" and not next_sibling.to_s.include?("FyrirsognMidSv")
          if next_sibling.to_s[0..5]=="<table"
            puts "============"      
            puts next_sibling.at("tr[1]/td[1]").text
            puts "============"
            if next_sibling.at("tr[1]/td[1]").text=="Þingskjöl"
              process_documents(next_sibling,current_process,process_document_type,process_type)
            elsif (next_sibling.at("tr[1]/td[1]").text)=="Umræða"
              process_discussion(next_sibling,current_process)
            end
          end
          next_sibling = next_sibling.next_sibling
        end
        puts "---------------------"
        old_process = current_process
        current_process = PriorityProcess.new
        current_process.process_type_id=process_type_record.id
        current_process.root_node = false
        current_process.parent_id = old_process.id
        current_process.priority_id = current_priority.id
        current_process.process_type = ProcessType.find_by_process_type("Althingi Process")
        current_process.stage_sequence_number=@@stage_sequence_number+=1
      end
    end
  end
end