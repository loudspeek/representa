#---------------------------------------------------------------------
# This should really be a scraper on morph but it blows its memory
# limits, so for now will just run locally
#---------------------------------------------------------------------

require 'colorize'
require 'csv'
require 'open-uri'
require 'pry'
require 'set'
require 'yajl/json_gem'

class ParlparseToCSV
  def self.parse(terms_csv, instructions_json)
    @terms = CSV.parse(open(terms_csv).read, headers: true, converters: :numeric, header_converters: :symbol)

    instructions_file = instructions_json or abort 'Need an instructions file'
    config = json_load(instructions_file)

    file = 'https://raw.githubusercontent.com/mysociety/parlparse/master/members/people.json'
    @json = json_load(file)
    posts = @json[:posts].find_all { |p| p[:organization_id] == config[:organization_id] }
    config[:period_overrides].each do |mid, pid|
      @json[:memberships].find { |m| m[:id] == "uk.org.publicwhip/member/#{mid}" }[:legislative_period_id] = pid
    end
    @json[:memberships].delete_if { |m| m.key?(:start_date) && m[:start_date] < config[:start_date] } if config.key? :start_date

    post_ids = posts.map { |p| p[:id] }.to_set

    rows = @json[:memberships].find_all { |m| post_ids.include?  m[:post_id] }.map do |m|
      person = @json[:persons].find { |p| p[:id] == m[:person_id] }
      party  = @json[:organizations].find { |o| o[:id] == m[:on_behalf_of_id] }
      post   = @json[:posts].find { |p| p[:id] == m[:post_id] }

      data = {
        id: person[:id].split('/').last,
        name: get_name(person),
        identifier__historichansard: person[:identifiers].to_a.find(->{{}}) { |id| id[:scheme] == 'historichansard_person_id' }[:identifier],
        identifier__datadotparl: person[:identifiers].to_a.find(->{{}}) { |id| id[:scheme] == 'datadotparl_id' }[:identifier],
        identifier__parlparse: person[:id],
        constituency: post[:area][:name],
        constituency_id: post[:id],
        party: party[:name],
        party_id: party[:id],
        start_date: m[:start_date],
        start_reason: m[:start_reason],
        end_date: m[:end_date],
        end_reason: m[:end_reason],
        term: m[:legislative_period_id] || term_id(m),
      }
    end

    [rows.first.keys.to_csv, rows.map { |r| r.values.to_csv }].join('')
  end

  private

  def self.json_load(file)
    JSON.parse(open(file).read, symbolize_names: true)
  end

  def self.display_name(name)
    if name.key? :lordname
      display = "#{name[:honorific_prefix]} #{name[:lordname]}"
      display += " of #{name[:lordofname]}" unless name[:lordofname].to_s.empty?
      return display
    end
    name[:given_name] + " " + name[:family_name]
  end

  def self.get_name(p)
    names = p[:other_names].select{|v| v.has_key?(:note) && v[:note] == "Main"}
    if names.count == 1
      return display_name(names.first)
    else
      return display_name(names.max_by{|v| v[:start_date] || "0000-00-00" })
    end
  end

  def self.term_id(m)
    s_date = m[:start_date]
    e_date = m[:end_date] || '2100-01-01'
    matched = @terms.find_all { |t| (s_date >= t[:start_date]) and (e_date <= (t[:end_date] || '2100-01-01')) }
    return matched.first[:id] if matched.count == 1
    puts "Too many terms".green if matched.count > 1
    puts "No terms".green if matched.count.zero?
    binding.pry
  end
end