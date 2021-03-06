require "rubygems"
require "dm-sweatshop"
require Merb.root / "spec" / "fixtures_helper"

# Examples:
# Book.fixture {{
#   :isbn         => random_isbn,
#   :created_at   => (1..100).pick.days.ago,
#   :short_title  => (short = /[:sentence:]{3,5}/.gen[0...50]),
#   :long_title   => /#{short} (\w+){1,3}/.gen,
#   :author       => Randgen.name,
#   :publisher    => "#{/\w+/.gen.capitalize} #{/\w+/.gen.capitalize}",
#   :notes        => /[:paragraph:]?/.gen,
#   :owner        => User.pick
# }}
# 
# User.fixture {{
#   :username     => username = /\w+/.gen.downcase,
#   :identity_url => "http://#{username}.example.com",
#   :email        => "#{username}@example.com",
#   :name         => Randgen.name
# }}
# 
# Reservation.fixture :completed, &completed_reservation
# Reservation.fixture :overdue, &overdue_reservation
# Reservation.fixture :checked_out, &checked_out_reservation
# 
# Review.fixture {{
#   :body       => /[:paragraph:]/.gen,
#   :score      => (1..5).pick,
#   :book       => (reservation = Reservation.pick(:completed)).book,
#   :user       => reservation.user
# }}

Comment.fixture{{
  :title =>  (short = /[:sentence:]{3,5}/.generate[0...50]),
  :raw => (raw = (1..(3)).of { /[:paragraph:]/.generate }.join("\n\n")),
  :html => raw,
  :markup => "textile",
  :email => /[:word:]@[:word:].com/.generate
}}

Article.fixture{{
  :title =>  /[:sentence:]{3,5}/.generate[0...50],
  :sub_title => /[:sentence:]{3,5}/.generate[0...30],
  :markup => "textile",
  :raw => (raw = (1..5).of { /[:paragraph:]/.generate }.join("\n\n")),
  :html => raw,
  :slug => /[:word:]/,
  :state => %w(draft preview published)[rand(3)]
}}

Blog.fixture{{
  :name => /[:word:]/.generate[0...32],
  :title =>  /[:sentence:]/.generate[0...128],
  :tagline => /[:sentence:]/.generate[0...128]
}}

User.fixture{{
  :email => /[:word:]@[:word:].com/.generate,
  :password => (password = /[:word:]/.generate),
  :password_confirmation => password
}}

3.of  { Blog.generate.save }
20.of { Article.generate.save }
30.of { Comment.generate.save }
5.of  { User.generate.save }

blogs = Blog.all
articles = Article.all

articles.each do |article|
  blog = blogs[rand(3)]
  BlogArticle.create(:blog => blog, :article => article)
end

blogs.each do |blog|
  #(index+3).times do
  #  BlogArticle.create(:blog => blog, :article => articles.pop)
  #end
  blog.update_attributes(:owner_id => User.get(rand(5)+3).id)
end

total_comments = Comment.all.length

Article.all.each do |article|
  comment = Comment.get(rand(total_comments)+1)
  comment.article_id = article.id if comment
end

