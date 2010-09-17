require 'fastercsv'

def create_tags(row)
  tags = []
  tags << row[1]
  tags << row[2]
  tags << row[3]
  tags << row[4]
  tags << row[5]
  tags << row[6]
  tags.join(",")
end



def create_priority_from_row(row,current_user,partner)
  priority_name = row[0].mb_chars.slice(0..59)
  priority_tags = create_tags(row)
  point_name = row[7].mb_chars.slice(0..59)
  point_text = row[8].mb_chars.slice(0..499)
  point_link = row[9]
  
  begin
    Priority.transaction do
      @priority = Priority.new
      @priority.name = priority_name
      @priority.user = current_user
      @priority.ip_address = "127.0.0.1"
      @priority.issue_list = priority_tags
      @priority.partner_id = partner.id
      puts @priority.inspect
      @saved = @priority.save
      puts @saved

      if @saved
        @question = Question.new
        @question.user = current_user
        @question.priority_id = @priority.id
        @question.content = point_text
        @question.name = point_name
        @question.value = 1
        @question.website = point_link if point_link and point_link != ""
        @question.partner_id = partner.id
        puts @question.inspect
        @question_saved = @question.save
      end
      puts @question_saved
      if @question_saved
        if Revision.create_from_point(@question.id,nil)
          @quality = @question.point_qualities.find_or_create_by_user_id_and_value(current_user.id,true)
        end      
      end
      raise "rollback" if not @question_saved or not @saved
    end
  rescue => e
    puts "ROLLBACK ERROR ON IMPORT"
    puts e.message
  end    
end

namespace :utils do
  desc "Archive processes"
  task(:create_esb_tags => :environment) do
      Tag.destroy_all
      ["Félagaréttur","Fjármálaþjónusta","Frjáls för fjármagns",
       "Frjáls för vinnuafls","Frjálst vöruflæði","Hugverkaréttur",
       "Opinber útboð","Samkeppnismál","Staðfesturéttur og þjónustufrelsi",
       "Upplýsingatækni og fjölmiðlum"].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t
        tag.weight = i
        tag.tag_type = 1
        tag.save
      end
      ["Evrópsk samgöngunet","Félagsmála- og atvinnustefna","Hagtölur",
      "Iðnstefna","Matvæla- og hreinlætismál","Menntun og menning","Neytenda- og heilsuvernd",
      "Orka","Samgöngur","Umhverfismál","Vísindi og rannsóknir"].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t
        tag.weight = i
        tag.tag_type = 2
        tag.save
      end
      ["Dóms- og innanríkismál","Fiskveiðar","Fjárhagslegt eftirlit",
      "Framlagsmál","Gjaldmiðilssamstarf","Landbúnaður og byggðastefna","Réttarvarsla og grundvallarréttindi",
      "Skattamál","Tollabandalag","Uppbyggingarstyrkir","Utanríkis-, öryggis- og varnamál",
      "Utanríkistengsl"].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t
        tag.weight = i
        tag.tag_type = 3
        tag.save
      end
  end
  desc "Archive processes"
  task(:archive_processes => :environment) do
      if ENV['current_thing_id']
        logg = "#{ENV['current_thing_id']}. lög"
        puts "Archiving all processes except for thing: #{logg}"
        Process.find(:all).each do |c|
          puts c.external_info_3
          unless c.external_info_3.index(logg)
            puts "ARCHIVING"
            c.archived = true
            c.save
          end
        end
      end
  end

  desc "Backup"
  task(:backup => :environment) do
      filename = "skuggaborg_#{Time.new.strftime("%d%m%y_%H%M%S")}.sql"
      system("mysqldump -u robert --password=X --force odd_dev_2 > /home/robert/#{filename}")
      system("gzip /home/robert/#{filename}")
      system("scp /home/robert/#{filename}.gz robert@where.is:backups/#{filename}.gz")
      system("rm /home/robert/#{filename}.gz")
  end

  desc "Delete Fully Processed Masters"
  task(:delete_fullly_processed_masters => :environment) do
      masters = ProcessSpeechMasterVideo.find(:all)
      masters.each do |master_video|
        puts "master_video id: #{master_video.id} all_done: #{master_video.process_speech_videos.all_done?} has_any_in_processing: #{master_video.process_speech_videos.any_in_processing?}"
        if master_video.process_speech_videos.all_done? and not master_video.process_speech_videos.any_in_processing?
          master_video_flv_filename = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/process_speech_master_videos/#{master_video.id}/master.flv"
          if File.exist?(master_video_flv_filename)
            rm_string = "rm #{master_video_flv_filename}"
            puts rm_string
            system(rm_string)
          end
        end
      end
  end

  desc "Delete Not Valid Video Folders"
  task(:delete_not_valid_video_folders => :environment) do
      Dir.entries("public/development/process_speech_videos").each do |filename|
        next if filename=="." or filename==".."
        unless ProcessSpeechVideo.exists?(filename.to_i)
          puts "rm -r public/development/process_speech_videos/#{filename}"
        else
          puts "Keeping public/development/process_speech_videos/#{filename}"
        end
      end
  end

  desc "Explore broken videos"
  task(:explore_broken_videos => :environment) do
      masters = ProcessSpeechMasterVideo.find(:all)
      masters.each do |master_video|
        unless master_video.process_speech_videos.all_done? and not master_video.process_speech_videos.any_in_processing?
          master_video_flv_filename = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/process_speech_master_videos/#{master_video.id}/master.flv"
          if File.exist?(master_video_flv_filename)
            puts "master_video id: #{master_video.id} all_done: #{master_video.process_speech_videos.all_done?} has_any_in_processing: #{master_video.process_speech_videos.any_in_processing?}"
            master_video.process_speech_videos.each do |video|
              puts "video id #{video.id} published #{video.published} #{video.title} in_processing #{video.in_processing} duration: #{video.duration_s} in: #{video.inpoint_s}"            
            end
            puts " "
          end
        end
      end
  end

  desc "Import priorities"
  task(:import_priorities => :environment) do
    @current_government = Government.last
    if @current_government
      @current_government.update_counts
      Government.current = @current_government
    end
    unless current_user = User.find_by_email("island@skuggathing.is")
      current_user=User.new
      current_user.email = "island@skuggathing.is"
      current_user.login = "Island.is"
      current_user.save(false)
    end
    f = File.open(ENV['csv_import_file'])
    partner = Partner.find_by_short_name(ENV['partner_short_name'])
    FasterCSV.parse(f.read) do |row|
      puts row.inspect
      create_priority_from_row(row, current_user, partner)  
    end
  end
end
