require 'nokogiri'

class Genome3dScraper < Tess::Scrapers::Scraper

  def self.config
    {
        name: 'Genome3D Scraper',
        offline_url_mapping: {},
        root_url: 'http://genome3d.eu'
    }
  end

  def scrape
    cp = add_content_provider(Tess::API::ContentProvider.new(
        { title: "Genome 3D",
          url: "http://genome3d.eu/",
          image_url: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQwd3d_tBGpERIc1QYAWERLLdesDHr-k41oASnaoNHzLVXVBPtYaQ",
          description: "Genome3D provides consensus structural annotations and 3D models for sequences from model organisms, including human.
  These data are generated by several UK based resources in the Genome3D consortium:
   SCOP, CATH, SUPERFAMILY, Gene3D, FUGUE, THREADER, PHYRE.",
          content_provider_type: Tess::API::ContentProvider::PROVIDER_TYPE[:PROJECT]
        }))

    lessons = {}

    doc = Nokogiri::HTML(open_url(config[:root_url] + '/tutorials/page/Public/Page/Tutorial/Index'))

    links = doc.css('#wiki-content-container').search('ul').search('li')
    links.each do |link|
      if !(a = link.search('a')).empty?
        href = a[0]['href'].chomp
        name = a.text
        puts "Name = #{a.text}" if debug
        puts "URL = #{a[0]['href'].chomp}" if debug
        description = nil
        if !(li = link.search('li')).empty?
          description = li.text
          puts "Description = #{li.text}" if debug
        end
        lessons[href] = {}
        lessons[href]['name'] = name
        lessons[href]['description'] = description.strip
      end
    end

    # Create the new record
    lessons.each do |path, data|
      add_material(Tess::API::Material.new(
          { title: data['name'],
            url: "#{config[:root_url]}/#{path}",
            short_description: data['description'],
            remote_updated_date: Time.now,
            remote_created_date: data['last_modified'],
            content_provider_id: cp['id']
          }))
    end
  end

end
