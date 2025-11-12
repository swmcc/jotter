# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default user
user = User.find_or_create_by!(email_address: "me@swm.cc") do |u|
  u.password = "password5"
  u.password_confirmation = "password5"
end

puts "✅ Seeded default user: me@swm.cc"

# Clear existing bookmarks for clean seeding
if user.bookmarks.any?
  puts "🧹 Clearing existing bookmarks..."
  user.bookmarks.destroy_all
end

# Sample bookmarks with real sites and relevant tags
bookmarks_data = [
  { title: "GitHub", url: "https://github.com", description: "Where the world builds software", tags: "dev, tools, git, opensource", public: true },
  { title: "Stack Overflow", url: "https://stackoverflow.com", description: "Q&A for developers", tags: "dev, programming, help, community", public: true },
  { title: "MDN Web Docs", url: "https://developer.mozilla.org", description: "Web technology documentation", tags: "dev, web, documentation, javascript", public: true },
  { title: "Tailwind CSS", url: "https://tailwindcss.com", description: "Utility-first CSS framework", tags: "css, design, frontend, framework", public: true },
  { title: "Ruby on Rails Guides", url: "https://guides.rubyonrails.org", description: "Official Rails documentation", tags: "rails, ruby, dev, backend", public: true },

  { title: "Hacker News", url: "https://news.ycombinator.com", description: "Tech news and discussion", tags: "news, tech, startups, community", public: true },
  { title: "Product Hunt", url: "https://producthunt.com", description: "Discover new products", tags: "products, startups, tech, inspiration", public: true },
  { title: "Indie Hackers", url: "https://indiehackers.com", description: "Community of indie founders", tags: "startups, indie, business, community", public: true },
  { title: "Dev.to", url: "https://dev.to", description: "Community of software developers", tags: "dev, blog, community, articles", public: true },
  { title: "CSS-Tricks", url: "https://css-tricks.com", description: "Web design articles and tutorials", tags: "css, design, frontend, tutorials", public: true },

  { title: "The Pragmatic Programmer", url: "https://pragprog.com", description: "Technical books for programmers", tags: "books, learning, programming, dev", public: false },
  { title: "Refactoring Guru", url: "https://refactoring.guru", description: "Design patterns and refactoring", tags: "dev, patterns, architecture, learning", public: true },
  { title: "Can I Use", url: "https://caniuse.com", description: "Browser support tables", tags: "web, frontend, compatibility, tools", public: true },
  { title: "Regex101", url: "https://regex101.com", description: "Regular expression tester", tags: "tools, dev, regex, testing", public: true },
  { title: "JSON Placeholder", url: "https://jsonplaceholder.typicode.com", description: "Free fake API for testing", tags: "api, testing, dev, tools", public: true },

  { title: "Dribbble", url: "https://dribbble.com", description: "Design inspiration community", tags: "design, inspiration, ui, portfolio", public: true },
  { title: "Behance", url: "https://behance.net", description: "Creative portfolios", tags: "design, portfolio, inspiration, creative", public: true },
  { title: "Figma", url: "https://figma.com", description: "Collaborative design tool", tags: "design, tools, ui, collaboration", public: true },
  { title: "Font Awesome", url: "https://fontawesome.com", description: "Icon library", tags: "icons, design, frontend, resources", public: true },
  { title: "Unsplash", url: "https://unsplash.com", description: "Free stock photos", tags: "photos, design, resources, free", public: true },

  { title: "AWS Documentation", url: "https://docs.aws.amazon.com", description: "Amazon Web Services docs", tags: "cloud, aws, devops, infrastructure", public: false },
  { title: "Docker Hub", url: "https://hub.docker.com", description: "Container image library", tags: "docker, devops, containers, tools", public: true },
  { title: "Kubernetes Docs", url: "https://kubernetes.io/docs", description: "Container orchestration", tags: "kubernetes, devops, containers, cloud", public: false },
  { title: "DigitalOcean Tutorials", url: "https://digitalocean.com/community/tutorials", description: "Server setup guides", tags: "devops, tutorials, hosting, learning", public: true },
  { title: "Heroku Dev Center", url: "https://devcenter.heroku.com", description: "Platform documentation", tags: "hosting, devops, paas, deployment", public: true },

  { title: "The Guardian", url: "https://theguardian.com", description: "UK news and journalism", tags: "news, uk, media, journalism", public: true },
  { title: "BBC News", url: "https://bbc.co.uk/news", description: "British news service", tags: "news, uk, media, current-events", public: true },
  { title: "Reuters", url: "https://reuters.com", description: "International news", tags: "news, world, journalism, current-events", public: true },
  { title: "Ars Technica", url: "https://arstechnica.com", description: "Technology news and reviews", tags: "tech, news, reviews, science", public: true },
  { title: "The Verge", url: "https://theverge.com", description: "Tech and culture", tags: "tech, news, culture, gadgets", public: true },

  { title: "Wikipedia", url: "https://wikipedia.org", description: "Free online encyclopaedia", tags: "reference, knowledge, learning, research", public: true },
  { title: "Khan Academy", url: "https://khanacademy.org", description: "Free online courses", tags: "education, learning, courses, free", public: true },
  { title: "Coursera", url: "https://coursera.org", description: "Online learning platform", tags: "education, courses, learning, university", public: true },
  { title: "MIT OpenCourseWare", url: "https://ocw.mit.edu", description: "Free MIT course materials", tags: "education, learning, university, free", public: false },
  { title: "freeCodeCamp", url: "https://freecodecamp.org", description: "Learn to code for free", tags: "coding, learning, tutorials, free", public: true },

  { title: "Postgres Documentation", url: "https://postgresql.org/docs", description: "PostgreSQL database docs", tags: "database, postgres, sql, dev", public: true },
  { title: "Redis Documentation", url: "https://redis.io/docs", description: "In-memory data store", tags: "database, redis, cache, dev", public: true },
  { title: "MongoDB Manual", url: "https://docs.mongodb.com/manual", description: "NoSQL database documentation", tags: "database, mongodb, nosql, dev", public: false },
  { title: "SQLite Home", url: "https://sqlite.org", description: "Embedded SQL database", tags: "database, sqlite, sql, embedded", public: true },
  { title: "Database Design Guide", url: "https://database.guide", description: "SQL tutorials and guides", tags: "database, sql, learning, tutorials", public: true },

  { title: "Linux Journey", url: "https://linuxjourney.com", description: "Learn Linux basics", tags: "linux, learning, tutorials, sysadmin", public: true },
  { title: "Vim Adventures", url: "https://vim-adventures.com", description: "Learn Vim through gaming", tags: "vim, tools, learning, editor", public: false },
  { title: "explainshell", url: "https://explainshell.com", description: "Shell command explanations", tags: "shell, linux, tools, learning", public: true },
  { title: "ShellCheck", url: "https://shellcheck.net", description: "Shell script linter", tags: "shell, tools, linting, dev", public: true },
  { title: "Bash Reference Manual", url: "https://gnu.org/software/bash/manual", description: "Official Bash documentation", tags: "bash, shell, reference, documentation", public: false },

  { title: "Lobsters", url: "https://lobste.rs", description: "Computing-focused community", tags: "tech, community, news, discussion", public: true },
  { title: "A List Apart", url: "https://alistapart.com", description: "Web design and development", tags: "web, design, articles, standards", public: true },
  { title: "Smashing Magazine", url: "https://smashingmagazine.com", description: "Web design magazine", tags: "design, web, articles, frontend", public: true },
  { title: "SitePoint", url: "https://sitepoint.com", description: "Web dev tutorials", tags: "web, tutorials, dev, learning", public: true },
  { title: "CodePen", url: "https://codepen.io", description: "Front-end code playground", tags: "frontend, tools, sandbox, inspiration", public: true }
]

puts "🔖 Creating #{bookmarks_data.length} bookmarks..."

bookmarks_data.each_with_index do |data, index|
  bookmark = user.bookmarks.create!(
    title: data[:title],
    url: data[:url],
    description: data[:description],
    is_public: data[:public],
    tag_list: data[:tags]
  )
  print "." if (index + 1) % 10 == 0
end

puts "\n✅ Created #{user.bookmarks.count} bookmarks"
puts "✅ Created #{Tag.count} unique tags"
puts "🔗 Short URLs available at /x/<short_code>"
