HOST = '192.168.1.1'
USER = 'admin'

SOURCES = [
  {
    url: 'http://gotblop.com/',
    query: 'a.link',
    clean: '/go?url='
  },
  {
    url: 'http://www.tblop.com/',
    query: '.list_contents a'
  }
]

(0..19).each do |i|
  SOURCES.push(
    url: "http://www.alexa.com/topsites/category;#{i}/Top/Adult",
    query: 'p.desc-paragraph a'
  )
end

def adultranking(type = 'free', offset = 0, max_page = 1)
  while offset >= 0
    start_page = adultranking_start_page(offset, max_page)
    finish_page = adultranking_finish_page(offset, max_page)
    (start_page..finish_page).each do |page|
      SOURCES.push(
        url: "http://adultsiteranking.com/home_sub2.asp?pg=#{offset}&page=#{offset+page}&x=#{type}&listtype=12",
        query: '.class2 a'
      )
    end
    offset -= 10
  end
end

def adultranking_start_page(offset, max_page)
  (offset + 1) <= max_page ? (offset + 1) : 0
end

def adultranking_finish_page(offset, max_page)
  (offset + 10) <= max_page ? (offset + 10) : max_page
end

adultranking('kp', 30, 35)
adultranking('free', 0, 2)
adultranking('shop', 0, 2)
adultranking('chat', 0, 3)

EXCLUDE = [
  'apple.com',
  'amazon.com',
  'youtube.com',
  'mozilla.org',
  'wepr0n.com',
  'ccleaner.com',
  'getfirefox.com',
  'google.com',
  'videolan.org',
  'imdb.com',
  'imggur.com',
  'subimg.net',
  'phapit.com',
  'upload.imagefap.com',
  'rapidshare.com',
  'torrentz.to',
  'dfiles.eu',
  'turbobit.net',
  'letitbit.net',
  'datafile.com',
  'vip-file.com',
  'rapidgator.net',
  'uploaded.net',
  'mydownloader.net',
  'gotblop.com',
  'tblop.com',
  'wikipedia.org',
  'en.wikipedia.org',
  'https:'
]

INCLUDE = [
  'xhamster.com',
  'bongacams.com',
  'xvideos.com',
  'youporn.com',
  'pornhub.com',
  'pornohub.com',
  'redtube.com',
  'nudevista.tv',
  '3movs.com',
  'sexed.su',
  'xnxx.com',
  'xshare.com',
  'youjizz.com',
  'sureporno.com',
  'smotri.com',
  'picred.com',
  'pornvideo.tv',
  'video.xnxx.com',
  'sexvideoonline.net',
  'dosug.cz',
  'runetki.com',
  'livejasmin.com',
  'intimatlas.com',
  'intimkin.ru',
  'intimkin.net',
  'stulchik.net',
  'intimcity.nl',
  'drtuber.com',
  'tumblr.com',
  'fuck',
  'porn'
]

namespace :filter do
  desc 'Update iptables firewall'
  task :update, [:password, :user, :host] do |_t, args|
    host = args[:host] || HOST
    user = args[:user] || USER
    password = args[:password]
    parser = FilterParser.new(sources: SOURCES)
    list = parser.list.delete_if { |url| EXCLUDE.include?(url) }
           .concat(INCLUDE)
           .uniq
    uploader = FilterUploader.new(host: host, user: user, password: password)
    uploader.upload_list(list)
    uploader.update_flash
  end
end
