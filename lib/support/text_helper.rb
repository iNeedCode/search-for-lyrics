module TextHelper
  
  def find_album_title_on_page(album_titles)
    best_match=0
    link_to_best_hit=""
  	white = Text::WhiteSimilarity.new
    similary=0
  	album_titles.each do |k,v|
      sim = white.similarity(@track[:title], k)
      if  sim > best_match && sim > MIN_PERCENT_MATCH
        link_to_best_hit = v
      end
    end
    link_to_best_hit
  end

end