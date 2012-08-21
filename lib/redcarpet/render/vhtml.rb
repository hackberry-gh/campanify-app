module Redcarpet
  module Render
    class VHTML < HTML
      def postprocess(document)
        
        # TODO: optimize it!
        # youtube
        
        iframes_youtube = []
        document.scan(/({youtube}\()(.*)(\))/).each do |youtube|
          
            if youtube[1].include?("http://www.youtube.com/embed/")
              video_url = youtube[1]
            elsif youtube[1].include?("http://youtu.be/")
              video_id = youtube[1].gsub('http://youtu.be/','')  
              video_url = "http://www.youtube.com/embed/#{video_id}"                    
            else  
              video_id = youtube[1].match(/(?<=[?&]v=)[^&$]+/)[0] unless youtube[1].match(/(?<=[?&]v=)[^&$]+/).nil?
              video_url = "http://www.youtube.com/embed/#{video_id}"          
            end
          
          iframes_youtube << iframe_tag(video_url)
        end
        
        document.scan(/{youtube}\(.*\)/).each_with_index do |youtube, i|
          document[youtube] = iframes_youtube[i]
        end
        
        
        # vimeo
        iframes_vimeo = []
        document.scan(/({vimeo}\()(.*)(\))/).each do |vimeo|
          
            # ?title=0&amp;byline=0&amp;portrait=0&amp;color=d13030
            if vimeo[1].include?("http://player.vimeo.com/video/")
              video_url = vimeo[1]
            elsif vimeo[1].include?("http://vimeo.com/")
              video_id = vimeo[1].gsub('http://vimeo.com/','')  
              video_url = "http://player.vimeo.com/video/#{video_id}"                    
            end
          
          iframes_vimeo << iframe_tag(video_url)
        end
        
        document.scan(/{vimeo}\(.*\)/).each_with_index do |vimeo, i|
          document[vimeo] = iframes_vimeo[i]
        end


        document
      end
      
      private
      
      def iframe_tag(video_url)
        "<iframe onload=\"$.campanify.resizeVideos();\" class=\"video\" src=\"#{video_url}\" frameborder=\"0\" webkitAllowFullScreen mozallowfullscreen  allowfullscreen></iframe>"
      end
      
    end
  end
end