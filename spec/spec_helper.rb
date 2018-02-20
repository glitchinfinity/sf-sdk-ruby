Dir[File.dirname(__FILE__) + '../lib/**/*.rb'].each do |f|
  puts "adding file #{f}"
  require f
end
require 'simplecov'
SimpleCov.add_filter('vendor')
SimpleCov.add_filter('spec')
SimpleCov.start

require 'webmock/rspec'
# require 'bundler/setup'
# Bundler.setup
require 'faker'
require 'securerandom'
require 'time'

require_relative '../lib/sfrest'
require_relative '../lib/sfrest/audit'
require_relative '../lib/sfrest/backup'
require_relative '../lib/sfrest/collection'
require_relative '../lib/sfrest/connection'
require_relative '../lib/sfrest/domains'
require_relative '../lib/sfrest/error'
require_relative '../lib/sfrest/group'
require_relative '../lib/sfrest/info'
require_relative '../lib/sfrest/role'
require_relative '../lib/sfrest/site'
require_relative '../lib/sfrest/stage'
require_relative '../lib/sfrest/task'
require_relative '../lib/sfrest/theme'
require_relative '../lib/sfrest/update'
require_relative '../lib/sfrest/user'
require_relative '../lib/sfrest/variable'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    @mock_endpoint = 'www.example.com'
    @mock_user = 'usermock'
    @mock_pass = 'passwordmock'
    @mock_headers = { 'Content-Type' => 'application/json' }

    # define a stub just in case. mostly this will need to be changed in each test case.
    stub_request(:any, /.*#{@mock_endpoint}.*/).with(headers: @mock_headers)
    define_task_statuses
  end
end

# webmock generators
def stub_factory(path = nil, return_body = nil, status = 200)
  return_data = { status: status }
  if return_body.is_a? Array
    return_data = []
    return_body.each { |body| return_data.push(status: status, body: body) }
  elsif return_body.is_a? Hash
    return_data = return_body
  else
    return_data[:body] = return_body
  end
  stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
    .with(headers: @mock_headers)
    .to_return(return_data)
end

def stub_json_request
  stub_factory(nil, '{"a":"b"}')
end

def stub_notjson_request
  stub_factory(nil, 'This is not json')
end

# data generation methods

def generate_domains
  domain_count = rand(1..3)
  domains = []
  domain_count.times do |i|
    domains[i] = SecureRandom.urlsafe_base64(5) + '.' +
                 SecureRandom.urlsafe_base64(5) + '.com'
  end
  domains
end

# individual collection data looks like
# { "id": 261, "time": "2016-11-25T13:18:44+00:00", "created": 1489075420,
#  "owner": "admin", "name": "collection1", "internal_domain": "collection1.site-factory.com",
#  "external_domains": [ "domain1.site-factory.com"], "groups": [ 91 ],
#  "sites": [ 236, 231], "primary_site" : 236 }
def generate_collection_data
  id = rand(1000).to_i
  created = rand(10**12).to_i
  time = Time.at(rand(10**12).to_i).strftime '%Y-%m-%dT%H:%M:%S+00:00'
  owner = SecureRandom.urlsafe_base64
  name = SecureRandom.urlsafe_base64
  internal_domain = "#{name}.#{SecureRandom.urlsafe_base64(5)}.com"
  domains = generate_domains
  sites_count = rand(1..3)
  sites = []
  sites_count.times { |i| sites[i] = rand(1000).to_i }
  primary_site = sites[0]
  group_count = rand(1..3)
  groups = []
  group_count.times { |i| groups[i] = rand(100).to_i }
  { 'id' => id, 'time' => time, 'created' => created,
    'owner' => owner, 'name' => name, 'internal_domain' => internal_domain,
    'external_domains' => domains, 'groups' => groups,
    'sites' => sites, 'primary_site' => primary_site }
end

# collections data looks like
#   { "count": 111, "time" : "2016-11-25T13:18:44+00:00",
#  "collections": [ { "id": 196, "name": "collection2",
#                      "internal_domain": "domain1.site-factory.com",
#                      "primary_site": 220,
#                      "site_count": 2,
#                      "groups": [ 91 ], }, ...] }
def generate_collections_data
  count = rand(1..100)
  collections = []
  time = Time.at(rand(10**12).to_i).strftime '%Y-%m-%dT%H:%M:%S+00:00'
  count.times do |i|
    collection_data = generate_collection_data
    collections[i] = { 'id' => collection_data['id'],
                       'name' => collection_data['name'],
                       'internal_domain' => collection_data['internal_domain'],
                       'primary_site' => collection_data['primary_site'],
                       'site_count' => collection_data['sites'].size,
                       'groups' => collection_data['groups'] }
  end
  { 'count' => count, 'time' => time, 'collections' => collections }
end

# creating a collection looks like
# { "id": 191, "name": "mycollection", "time": "2016-11-25T13:18:44+00:00",
#  "internal_domain": "mycollection.site-factory.com" }
def generate_collection_creation_data(internal_domain = nil)
  id = rand(1000).to_i
  name = SecureRandom.urlsafe_base64
  time = Time.at(rand(10**12).to_i).strftime '%Y-%m-%dT%H:%M:%S+00:00'
  internal_domain ||= "#{name}.#{SecureRandom.urlsafe_base64(5)}.com"
  { 'id' => id, 'name' => name, 'time' => time, 'internal_domain' => internal_domain }
end

# deleting a collection looks like
# { "id" : 101, "time" : "2016-10-28T09:25:26+00:00", "deleted" : true,
# "message" : "Your site collection was successfully deleted." }
def generate_collection_deletion_data
  id = rand(1000).to_i
  time = Time.at(rand(10**12).to_i).strftime '%Y-%m-%dT%H:%M:%S+00:00'
  message = Faker::Lorem.sentence
  deleted = heads?
  { 'id' => id, 'deleted' => deleted, 'time' => time, 'message' => message }
end

# adding sites to a collection looks like
# { "id" : 101, "name": "mycollection", "time" : "2016-10-28T09:25:26+00:00",
#  "sites_added" : [123], "added": true,
#  "message" : "One site was successfully added to the site collection." }
def generate_collection_add_site_data
  id = rand(1000).to_i
  name = SecureRandom.urlsafe_base64
  time = Time.at(rand(10**12).to_i).strftime '%Y-%m-%dT%H:%M:%S+00:00'
  site_count = rand(1..3)
  sites = []
  site_count.times { |i| sites[i] = rand(100).to_i }
  message = Faker::Lorem.sentence
  added = heads?
  { 'id' => id, 'name' => name, 'time' => time, 'sites_added' => sites, 'added' => added, 'message' => message }
end

# removing from a collection looks like
# { "id" : 101, "name": "mycollection", "time" : "2016-10-28T09:25:26+00:00",
#  "sites_ids_removed" : [123], "removed": true,
#  "message" : "One site was successfully removed from the site collection." }
def generate_collection_remove_site_data
  id = rand(1000).to_i
  name = SecureRandom.urlsafe_base64
  time = Time.at(rand(10**12).to_i).strftime '%Y-%m-%dT%H:%M:%S+00:00'
  site_count = rand(1..3)
  sites = []
  site_count.times { |i| sites[i] = rand(100).to_i }
  message = Faker::Lorem.sentence
  removed = heads?
  { 'id' => id,
    'name' => name,
    'time' => time,
    'site_ids_removed' => sites,
    'removed' => removed,
    'message' => message }
end

# making a site primary in a collection looks like
# { "id" : 101, "name": "mycollection", "time" : "2016-10-28T09:25:26+00:00",
#  "primary_site_id" : 123, "switched": true,
#  "message" : "It can take a few minutes to switch over to the new primary site." }
def generate_collection_set_primary_site_data
  id = rand(1000).to_i
  name = SecureRandom.urlsafe_base64
  time = Time.at(rand(10**12).to_i).strftime '%Y-%m-%dT%H:%M:%S+00:00'
  site = rand(100).to_i
  message = Faker::Lorem.sentence
  switched = heads?
  { 'id' => id,
    'name' => name,
    'time' => time,
    'primary_site_id' => site,
    'switched' => switched,
    'message' => message }
end

# getting Site Factory information looks like
# { "factory_version": "2.60.0.2248+20170521",
#  "time": "2016-10-28T09:25:26+00:00" }
def generate_info_data
  factory_version = SecureRandom.urlsafe_base64
  time = Time.at(rand(10**12).to_i).strftime '%Y-%m-%dT%H:%M:%S+00:00'
  { 'factory_version' => factory_version,
    'time' => time }
end

#  individual site data looks like
# {"id":96,"created":1441224920,"owner":"nik_admin","site":"s1",
# "domains":["s1.checkphpsf.utest.acquia-test.com"],"groups":[91]}
# {'id' => int, 'created' => int, 'owner' => string, 'site' => string,
# 'domains' => [string, string,...], 'groups' => [int, int, ...]}
def generate_site_data
  id = rand(1000).to_i
  created = rand(10**12).to_i
  owner = SecureRandom.urlsafe_base64
  site = SecureRandom.urlsafe_base64
  group_count = rand(1..3)
  groups = []
  group_count.times { |i| groups[i] = rand(100) }
  domains = generate_domains
  { 'id' => id, 'created' => created, 'owner' => owner, 'site' => site, 'domains' => domains, 'groups' => groups }
end

# sites data looks like
# {"count":"11","sites":[{"id":96,"site":"s1","domain":"s1.checkphpsf.utest.acquia-test.com"},
# {"id":1647,"site":"s2","domain":"s2.checkphpsf.utest.acquia-test.com"},
# {"id":2821,"site":"s3","domain":"s3.checkphpsf.utest.acquia-test.com"},
# {"id":9131,"site":"drush1458293795clean","domain":"drush1458293795clean.checkphpsf.utest.acquia-test.com"},
# {"id":9136,"site":"drush1458294074full","domain":"drush1458294074full.checkphpsf.utest.acquia-test.com"},
# {"id":11396,"site":"rest1459854527clean","domain":"rest1459854527clean.checkphpsf.utest.acquia-test.com"},
# {"id":13491,"site":"rest1460649250","domain":"rest1460649250.checkphpsf.utest.acquia-test.com"},
# {"id":13496,"site":"rest1460649900","domain":"rest1460649900.checkphpsf.utest.acquia-test.com"},
# {"id":13501,"site":"rest1460650550","domain":"rest1460650550.checkphpsf.utest.acquia-test.com"},
# {"id":13506,"site":"rest1460651076","domain":"rest1460651076.checkphpsf.utest.acquia-test.com"}]}
#
# {'count' => int,
# sites => Array(site_data[{id, site, 1st domain}])[count]}
def generate_sites_data
  count = rand(1..100)
  sites = []
  count.times do |i|
    site_data = generate_site_data
    sites[i] = { 'id' => site_data['id'], 'site' => site_data['site'], 'domain' => site_data['domains'][0] }
  end
  { 'count' => count, 'sites' => sites }
end

# site creation data looks like
# {"id":"13516","site":"asite","domains":["asite.checkphpsf.utest.acquia-test.com"],"groups":[91]}
# {'id' => int, 'site' => string, 'domains' => [string, string,...], 'groups' => [int, int, ...]}
def generate_site_creation_data
  groups = []
  group_count = rand(1..3)
  group_count.times { |i| groups[i] = rand(100) }
  domain_count = rand(1..3)
  domains = []
  domain_count.times do |i|
    domains[i] = SecureRandom.urlsafe_base64(5) + '.' +
                 SecureRandom.urlsafe_base64(5) + '.com'
  end
  { 'id' => rand(1000), 'site' => SecureRandom.urlsafe_base64, 'domains' => domains, 'groups' => groups }
end

# site delete data looks like
# { 'id' => int, 'owner' => string, 'site' => string, 'time' => ISO 8601 date, 'task_id' => int}
def generate_site_delete_data
  { 'id' => rand(1000),
    'owner' => SecureRandom.urlsafe_base64,
    'site' => SecureRandom.urlsafe_base64,
    'time' => Time.now.utc.iso8601,
    'task_id' => rand(10**5) }
end

# site duplicate data looks like
# { "id": 183, "site": "mysite2"}
# { 'id' => int, 'site' => string}
def generate_site_duplicate_data
  { 'id' => rand(1000), 'site' => SecureRandom.urlsafe_base64 }
end

# site backup creation data
#  { "task_id": 183 }
#  { 'task_id' => int }
def generate_task_id
  { 'task_id' => rand(10**5) }
end

# individual backup data
# {"id":4336, "nid":96, "status":true, "uid":16, "timestamp":1460653300,
# "bucket":"acsf-gardens-dev-backup-us-east-1",
# "directory":"acsf-backup-jenkins-ci\/prod",
# "file":"s1_96_1460653300.tar.gz", "label":"nikbackup"}
#
# {'id' => int, 'nid' => int, 'status' => boolean, 'uid' => int,
# 'timestamp' => int, 'bucket' => string, 'file' => string, 'label' => string}
def generate_backup_data
  id = rand(10**5)
  nid = rand(10**5)
  status = heads?
  uid = rand(1000)
  timestamp = rand(10**12)
  bucket = SecureRandom.urlsafe_base64
  file = SecureRandom.urlsafe_base64(100)
  label = SecureRandom.urlsafe_base64(30)
  { 'id' => id, 'nid' => nid, 'status' => status, 'uid' => uid,
    'timestamp' => timestamp, 'bucket' => bucket, 'file' => file,
    'label' => label }
end

# site backup list data
# {"backups":[{"id":4336,
# "nid":96,
# "status":true,
# "uid":16,
# "timestamp":1460653300,
# "bucket":"acsf-gardens-dev-backup-us-east-1",
# "directory":"acsf-backup-jenkins-ci\/prod",
# "file":"s1_96_1460653300.tar.gz",
# "label":"nikbackup"},
# {"id":4331,
# "nid":96,
# "status":true,
# "uid":116,
# "timestamp":1460653127,
# "bucket":"acsf-gardens-dev-backup-us-east-1",
# "directory":"acsf-backup-jenkins-ci\/prod",
# "file":"s1_96_1460653127.tar.gz",
# "label":"drush1460653067"}],
# "count":"407"}
# {'backups' => [backup_data, backup_data, ...], count => int}
def generate_backups_data
  count = rand(1000)
  backups = []
  count.times { |i| backups[i] = generate_backup_data }
  { 'backups' => backups, 'count' => count }
end

# backup url data
# { "url": "https://<awss3url>",
#    "lifetime": 300 }
# { 'url' => string, 'lifetime' => int }
# see generate_task_id
def generate_backup_url_data
  { 'lifetime' => rand(1000),
    'url' => 'https://' + SecureRandom.urlsafe_base64(4) + '.' + SecureRandom.urlsafe_base64 + '.com' }
end

# backup delete data
# { "task_id": 16 }
# {'task_id' => int}
# see generate_task_id

# backup restore data
# { "task_id": 16 }
# {'task_id' => int}
# see generate_task_id

# task status data
# { "wip_task": { "id": "47", "status": "16"} "time": "2014-05-02T16:21:25+00:00"}
# {'wip_task' => {'id' => int, 'status'=> intish}, 'time' => datestring}
def generate_task_status(status)
  { 'wip_task' => { 'id' => rand(10**5), 'status' => status }, 'time' => SecureRandom.base64 }
end

# task data looks like
# [
# {
#     "added": "1460808005",
#     "class": "Acquia\\SfCron\\MultisiteCron",
#     "completed": "1460808079",
#     "concurrency_exceeded": "0",
#     "error_message": "",
#     "group_name": "MultisiteCron",
#     "id": "410196",
#     "lease": "180",
#     "max_run_time": "300",
#     "name": "MultisiteCron tangle_checkphp 1",
#     "nid": "0",
#     "object_id": "410196",
#     "parent": "407996",
#     "paused": "0",
#     "priority": "2",
#     "started": "1460808009",
#     "status": "16",
#     "taken": "0",
#     "uid": "0",
#     "wake": "1460808079"
# },
#
# [task_hash1, task_hash2]
# task_hash looks like
# {'added'=> EPOCHTIME, 'class' => string, 'completed' => EPOCHTIME, 'concurrency_exceeded' => 0|1,
# error_message => string, 'group_name' => string, 'id' => int, 'lease' => int,
# 'max_run_time' => int, 'name' => string, 'nid' => int, 'object_id' => int,
# 'parent' => int, 'paused' => 0|1, 'priority' => 0|1|2|3, 'started' => int
# 'status' => intish, 'taken' => 0|1, 'uid' => int, 'wake' => EPOCHTIME}

def generate_task_data
  added = time_rand
  wake = added + rand(300)
  started = wake + rand(300)
  completed = started + rand(300)
  clazz = SecureRandom.urlsafe_base64
  concurrency_exceeded = rand 2
  error_message = SecureRandom.urlsafe_base64
  group_name = SecureRandom.urlsafe_base64
  id = rand 10**6
  lease = rand 300
  max_run_time = rand 300
  name = SecureRandom.urlsafe_base64
  nid = rand 10**6
  object_id = rand 10**6
  parent = rand 10**6
  paused = rand 3
  priority = rand 4
  status = generate_random_task_status
  taken = rand 2
  uid = rand 10**5

  { 'added' => added, 'class' => clazz, 'completed' => completed,
    'concurrency_exceeded' => concurrency_exceeded, 'error_message' => error_message,
    'group_name' => group_name, 'id' => id, 'lease' => lease, 'max_run_time' => max_run_time,
    'name' => name, 'nid' => nid, 'object_id' => object_id, 'parent' => parent, 'paused' => paused,
    'priority' => priority, 'status' => status, 'taken' => taken, 'uid' => uid }
end

def generate_tasks(count = 1000)
  count = rand(count)
  tasks = []
  count.times { |i| tasks[i] = generate_task_data }
  tasks
end

def generate_random_task_status
  define_task_statuses
  @all_statuses.sample
end

# group data
# individual gorup data looks like
# { "created": 1460975803, "group_id": 14031, "group_name": "Test1460975802platform admin",
# "owner": "nik.admin_pa", "owner_id": 121, "status": 1}
#
# {'created' => time_rand, 'group_id' => int, 'group_name' => string,
# 'owner' => string, 'owner_id' => int, 'status' => 0|1}
def generate_group_data
  group_id = rand(1000).to_i
  created = time_rand
  group_name = SecureRandom.urlsafe_base64
  owner = SecureRandom.urlsafe_base64
  owner_id = rand(1000).to_i
  status = rand 2
  { 'group_id' => group_id, 'created' => created, 'group_name' => group_name,
    'owner' => owner, 'owner_id' => owner_id, 'status' => status }
end

# groups data looks like
# {'count' => int, 'groups' => [group, group, group, ...]}
def generate_groups_data
  count = rand(1..100)
  groups = []
  count.times do |i|
    group_data = generate_group_data
    groups[i] = group_data
  end
  { 'count' => count, 'groups' => groups }
end

#  individual user data looks like
# { "access": "1441373652", "created": "1441370426", "mail": "balazs.nagykekesi@acquia.com", "name": "balazs",
# "roles": { "11": "administrator", "2": "authenticated user"},
# "status": "1", "tfa_status": "active", "uid": "31"}
# {'uid' => int, 'access' => timeint,  'created' => timeint, 'mail' => string, 'name' => string,
# 'status' => 0|1, 'tfa_status' => 'active|unknown', 'roles' =<{ int => string, int => string,...}}
def generate_user_data
  uid = rand(1000).to_i
  created = time_rand
  accessed = time_rand + rand(10**5)
  mail = SecureRandom.urlsafe_base64 + '@example.com'
  name = SecureRandom.urlsafe_base64
  role_count = rand(1..3)
  roles = role_candidates.to_a.sample(role_count).to_h
  tfa_status_candidates = %w[active unknown disabled]
  { 'uid' => uid, 'accessed' => accessed, 'created' => created, 'mail' => mail, 'name' => name,
    'status' => rand(2), 'roles' => roles,
    'tfa_status' => tfa_status_candidates.sample }
end

# users data looks like
# { "count": 73, "users": [ { "access": "1439407295", "created": "1439407057", "mail": "admin@example.com",
# "name": "admin",
# "roles": { "11": "administrator", "16": "release engineer", "21": "developer"},
# "status": "blocked", "tfa_status": "unknown", "uid": "1"}, {}, {} ]
#
# {'count' => int,
# users => Array(site_data[{id, site, 1st domain}])[count]}
def generate_users_data
  count = rand(1..100)
  users = []
  count.times do |i|
    user_data = generate_user_data
    user_data['status'] = user_data['status'] == 0 ? 'blocked' : 'active'

    users[i] = user_data
  end
  { 'count' => count, 'users' => users }
end

# role data

def generate_roles_data
  role_count = rand 50
  roles = {}
  last_acquia_rid = role_candidates.keys.sort.last
  role_count.times do |i|
    rid = last_acquia_rid + 5 * (i + 1)
    rname = SecureRandom.urlsafe_base64
    roles[rid] = rname
  end
  roles = role_candidates.merge roles
  { 'count' => roles.size, 'roles' => roles }
end

def role_candidates
  { 11 => 'administrator',
    16 => 'release engineer',
    21 => 'developer',
    26 => 'bulk site manager',
    31 => 'platform admin',
    36 => 'site builder',
    41 => 'acquia employee',
    46 => 'ra' }
end

def heads?
  chance = [0, 1].sample
  chance == 0
end

def time_rand(from = 0.0, to = Time.now)
  Time.at(from + rand * (to.to_f - from.to_f))
end

def define_task_statuses
  @running_statuses = [SFRest::Task::STATUS_WAITING,
                       SFRest::Task::STATUS_IN_PROCESS]
  @not_started_statuses = [SFRest::Task::STATUS_NOT_STARTED,
                           SFRest::Task::STATUS_RESTARTED,
                           SFRest::Task::STATUS_TO_BE_RUN]
  @finished_statuses = [SFRest::Task::STATUS_COMPLETED,
                        SFRest::Task::STATUS_ERROR,
                        SFRest::Task::STATUS_KILLED,
                        SFRest::Task::STATUS_WARNING,
                        SFRest::Task::STATUS_DONE]
  @not_finished_statuses = @not_started_statuses + @running_statuses
  @completedish_statuses = [SFRest::Task::STATUS_COMPLETED,
                            SFRest::Task::STATUS_WARNING,
                            SFRest::Task::STATUS_DONE]
  @all_statuses = @not_finished_statuses + @finished_statuses
end
