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
    query: '.list_contents a',
  }
]

EXCLUDE = [
  'apple.com',
  'amazon.com',
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
  'tblop.com'
]

INCLUDE = [
  "xhamster.com",
  "bongacams.com",
  "xvideos.com",
  "youporn.com",
  "pornhub.com",
  "pornohub.com",
  "redtube.com",
  "3movs.com",
  "sexed.su",
  "xnxx.com",
  "xshare.com",
  "youjizz.com",
  "sureporno.com",
  "smotri.com",
  "picred.com",
  "pornvideo.tv",
  "video.xnxx.com",
  "sexvideoonline.net",
  "dosug.cz",
  "runetki.com",
  "livejasmin.com",
  "intimatlas.com",
  "intimkin.ru",
  "intimkin.net",
  "stulchik.net",
  "intimcity.nl",
  "drtuber.com",
  "tumblr.com"
]

namespace :filter do
  desc 'Update iptables firewall'
  task :update, [:password, :user, :host] do |t, args|
    host = args[:host] || HOST
    user = args[:user] || USER
    password = args[:password]
    parser = FilterParser.new(sources: SOURCES)
    list = parser.list.delete_if { |url| EXCLUDE.include?(url) }.concat(INCLUDE).uniq
    uploader = FilterUploader.new(host: host, user: user, password: password)
    uploader.upload_list(list)
    uploader.update_iptables
  end
end
